#!/bin/bash

curl \
	--header "Content-Type: application/json" \
	-X POST \
	--data-binary "{ \"ResetType\": \"AuxCycle\" }" \
	https://$ilo/redfish/v1/Systems/1/Actions/Oem/Hp/ComputerSystemExt.SystemReset/ \
	-u Administrator:password \
	--insecure

