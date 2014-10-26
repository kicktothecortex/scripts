#!/bin/bash

HEIGHT="0"; WIDTH="0"; ASPECT="0";

declare $(ffprobe -v 0 -show_streams -of flat=s=_:h=0 "$1" | grep -E 'width|height')

if [[ ${stream_0_height} -ge "480" && ${stream_0_height} -lt "720" ]]; then
	HEIGHT="480";
elif [[ ${stream_0_height} -ge "720" ]]; then
	HEIGHT="720";
else
	HEIGHT="${stream_0_height}";
fi
ASPECT=$(echo "${stream_0_width}/${stream_0_height}" | bc -l);
WIDTH=$(echo "scale=0;$HEIGHT*$ASPECT/1" | bc -l);
echo "Aspect: $ASPECT
Original size: ${stream_0_width}x${stream_0_height}
Calculated scaling size: ${WIDTH}x${HEIGHT}";