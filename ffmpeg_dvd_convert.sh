#!/bin/bash

# ffmpeg -i S01E02\ -\ While\ You\ Were\ Sleeping.mkv -target ntsc-dvd -r 23.98 -vf scale=720:480 -aspect 16:9 -b:v 4M S01E02\ -\ While\ You\ Were\ Sleeping.mpeg

TEST=0;
EXT_LIST='avi|mkv|mpg|mpeg|flv|wmv|mov|mp4|f4v';

for FILENAME in *; do
	EXT="${FILENAME#*.}"
	if [[ -f $FILENAME && $EXT =~ $EXT_LIST ]]; then
		NAME="${FILENAME%.*}"
		echo -e "$FILENAME is being processed for video DVD - NTSC"
		#ffmpeg -y -threads 5 -i "$FILENAME" -target ntsc-dvd -r 29.97 -vf scale=720:480 -aspect 16:9 -b:v 3M -an -pass 1 "$NAME.mpeg"
		#ffmpeg -y -threads 5 -i "$FILENAME" -target ntsc-dvd -r 29.97 -vf scale=720:480 -aspect 16:9 -b:v 3M -c:a ac3 -ab 128k -ac 2 -pass 2 "$NAME.mpeg"
		ffmpeg -y -threads 5 -i "$FILENAME" -target ntsc-dvd -r 29.97 -vf scale=720:480 -aspect 16:9 -b:v 3M -c:a ac3 -ab 128k -ac 2 "$NAME.mpeg"
	fi
done
