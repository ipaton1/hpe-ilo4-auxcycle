# iLO 4 AuxCycle

newer iLO 4 firmware (>2.55) includes a feature called AuxPwrCycle it's briefly
mentioned in the doc for reformatting the iLO 4 flash:
[https://support.hpe.com/hpesc/public/docDisplay?docId=a00048622en_us&docLocale=en_US](https://support.hpe.com/hpesc/public/docDisplay?docId=a00048622en_us&docLocale=en_US)
[https://support.hpe.com/hpesc/public/docDisplay?docId=a00048622en_us&docLocale=en_US](https://support.hpe.com/hpesc/public/docDisplay?docId=a00048622en_us&docLocale=en_US)
but no details are ever given. 
some searching will turn up a few references to people using it
and another HPE doc:
[https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-a00047494en_us](https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-a00047494en_us)
that supposedly documents AuxPwrCycle but when you follow that link it's just 
giving you a 'document is unavailable' message

Turns out what you want is to look at this documentation on the newer redfish
based way to config the ilo [https://hewlettpackard.github.io/ilo-rest-api-docs/ilo4](https://hewlettpackard.github.io/ilo-rest-api-docs/ilo4)
however even then it's not documented!
There is mention of it in the iLO5 & iLO6 versions of that documentation,
but no description of what it does or how to use it.  Nope, before you ask
this is only available in the redfish API, but the original mention was so
vague you'd never know that

the redfish API has been designed by someone with a bit of a clue and you can 
actually ask it what's supported. convoluted PITA json crap, but still..

doing a GET against `https://$host/redfish/v1/Systems/1/` will get you back
a bit of json that describes what you need to do - have to be using http**s** and
authenticated to get it though.
(bit of chicken and egg problem there, you need to know how to talk to it
 before you can get it to tell you how to talk to it, D'Oh)

buried in there under the Oem section you'll find this

```
  "Oem": {
    "Hp": {
      "@odata.type": "#HpComputerSystemExt.1.2.2.HpComputerSystemExt",
      "Actions": {
        "#HpComputerSystemExt.PowerButton": {
          "PushType@Redfish.AllowableValues": [
            "Press",
            "PressAndHold"
          ],
          "target": "/redfish/v1/Systems/1/Actions/Oem/Hp/ComputerSystemExt.PowerButton/"
        },
        "#HpComputerSystemExt.SystemReset": {
          "ResetType@Redfish.AllowableValues": [
            "ColdBoot",
            "AuxCycle"
          ],
          "target": "/redfish/v1/Systems/1/Actions/Oem/Hp/ComputerSystemExt.SystemReset/"
        }
      },
```

which gives you the target of 
`/redfish/v1/Systems/1/Actions/Oem/Hp/ComputerSystemExt.SystemReset/`
and the possible options of ColdBoot & AuxCycle... Yes **AuxCycle** when it was mentioned in
the original doc as **Aux_Pwr_Cycle** - you've been searching for the wrong thing! 


there's a way to do this with curl however I had lots of problems with curl mangling
the quotes in the json, quite clear when you grab the 'trace' output and even 
--data-binary didn't help


Problems I saw both with curl and LWP in perl were that something was translating 
a double quote char " or 0x22 into a 'left double quote' 0xE2 0x80 0x9C 
followed by a 'right double quote' 0xE2 0x80 0x9D. This ended up being hard to debug
as whenever you printed the string or looked at the contents of a file all of these 
different quotes appeared exactly the same.
Sooner or later you end up in wireshark trying to debug and discover the
Content-Length header is wrong and wireshark gives the actual bytes on the
wire exposing the problem.

