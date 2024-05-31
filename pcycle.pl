#!/usr/bin/perl

use strict;
use warnings;
use MIME::Base64;
use LWP::UserAgent;

# keep this as simple as possible to avoid as many superflous deps as we can
# the idea being that we demonstrate a simple way to do this without a massive maze of 
# deps and abstraction layers to cloud what's going on

my $host="192.168.0.1";
my $user="Administrator";
my $password="06396138";

# we're using Basic auth here. The redfish API has a much more complex setup for doing
# more involved stuff where you 'login' get a token, do lots of operations using the token,
# then logout. We don't need that here as we only want to hard power cycle the server

my $encoded_auth = encode_base64("$user:$password", '');

# you need to get this right as the iLO appears to be highly pernickety about 'malformed json'
# but never wants to give you a hint about what's malformed
my $a = '{ "ResetType": "AuxCycle" }';

my $req = HTTP::Request->new( POST => "https://$host/redfish/v1/Systems/1/Actions/Oem/Hp/ComputerSystemExt.SystemReset/",['Content-Type' => 'application/json','Authorization' => "Basic $encoded_auth"]);

$req->content($a);

my $ua = LWP::UserAgent->new;

# disable certificate verification as just about everyone leaves these with the 
# default self signed certs that are not verifiable... let's face it, does anyone
# really want to advertise their whole internal infrastructure in a publically visible
# Certificate Transparency log? Nope.
$ua->ssl_opts(SSL_verify_mode => 0);
$ua->ssl_opts(verify_hostname => 0);

my $rsp = $ua->request( $req );

print $rsp->code . "\n". $rsp->content . "\n";

