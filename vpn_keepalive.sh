#!/bin/bash

TEXAS="ba1cd0b8-d898-4d8d-94a0-13ed7da1937c"		# Texas
EAST="78515804-1306-46bd-b50d-2933419244bb"		# East
MIDWEST="c6b2ecfc-a8cc-46c7-8f16-6e6bdad71db4"		# Midwest
WEST="be42394d-5a20-4836-a2b7-f7ba6d2b6bf6"		# West
SEATTLE="44df2996-34a8-4a5a-a349-ff9112c9c649"		# Seattle
SWEDEN="3f268a51-7249-46f4-9751-479c31338a86"		# Sweden

while [ "true" ]
do
	case `shuf -i1-6 -n1` in
		"1") VPN_UUID=$TEXAS;;
		"2") VPN_UUID=$EAST;;
		"3") VPN_UUID=$WEST;;
		"4") VPN_UUID=$MIDWEST;;
		"5") VPN_UUID=$SEATTLE;;
		"6") VPN_UUID=$SWEDEN;;
	esac
	VPNCON=$(nmcli c status)
	if [[ $VPNCON != *PIA* ]]; then
		#echo "Disconnected, trying to reconnect..."
		(sleep 1s && nmcli c up uuid $VPN_UUID)
	#else
		#echo "Already connected !"
	fi
	sleep 10
done
