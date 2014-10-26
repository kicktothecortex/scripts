#!/bin/bash

USBDRIVE="/media/usb"
INFILE="$1"
#USBDRIVE="$2"
#SMOVIES="/data/movies/"
#DMOVIES="/portamedia/Movies/"

## rsync command
# Change based on destination file system... fat32 needs special options

# Normal rsync
#RCOMMAND='rsync -vah --delete --progress "$SPATH" "$DPATH"'
# FAT32 rsync
RCOMMAND='rsync -rtvh --modify-window 2 --delete --progress "$SPATH" "$DPATH"'

# Media Sync
echo
while read LINE
do
	echo "
	++++ SYNCING $LINE ++++
	"
	if $(echo $LINE | grep --quiet movies); then
		SUBPATH="movies"
	#elif $(echo $LINE | grep --quiet cartoons); then
	#	SUBPATH="cartoons"
	else
		SUBPATH="tv_shows"
	fi
	SPATH="/data/$LINE"
	DPATH="$USBDRIVE/$SUBPATH"
	echo $RCOMMAND
	eval $RCOMMAND
done <$INFILE
