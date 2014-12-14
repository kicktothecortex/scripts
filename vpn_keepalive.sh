#!/bin/bash

#VPN_UUID="043164c9-05bf-42ad-83f4-bc368d246326"		# East
VPN_UUID="16b49df3-c1d5-4c82-9d2d-b9f9398ded33"		# Midwest

while [ "true" ]
do
	VPNCON=$(nmcli c status)
	if [[ $VPNCON != *PIA* ]]; then
		#echo "Disconnected, trying to reconnect..."
		(sleep 1s && nmcli c up uuid $VPN_UUID)
	#else
		#echo "Already connected !"
	fi
	sleep 10
done
