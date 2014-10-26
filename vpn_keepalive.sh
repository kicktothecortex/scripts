#!/bin/bash
while [ "true" ]
do
	VPNCON=$(nmcli c status)
	if [[ $VPNCON != *PIA* ]]; then
		#echo "Disconnected, trying to reconnect..."
		(sleep 1s && nmcli c up uuid 16b49df3-c1d5-4c82-9d2d-b9f9398ded33)
	#else
		#echo "Already connected !"
	fi
	sleep 10
done
