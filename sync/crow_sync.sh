#!/bin/bash

USBDRIVE="/media/crow"
INFILE="$1"

## rsync command
# Change based on destination file system... fat32 needs special options

## Normal rsync
# RCOMMAND='rsync -vah --delete --progress "$SPATH" "$DPATH"'
## FAT32 rsync
# RCOMMAND='rsync -rtvh --modify-window 2 --delete --progress "$SPATH" "$DPATH"'

# Media Sync
echo
while read LINE
do
	echo "
	++++ SYNCING $LINE ++++
	"
	if $(echo $LINE | grep --quiet movies); then
		SUBPATH="movies"
		SOURCE="/data/$LINE/"
		DEST="$USBDRIVE/$SUBPATH"
		RCOMMAND='rsync -rtvh --modify-window 2 --progress --include="*/" --include-from include-list --exclude="*" "'$SOURCE'" "'$DEST'"'
	#elif $(echo $LINE | grep --quiet cartoons); then
	#	SUBPATH="cartoons"
	else
		SUBPATH="tv_shows"
		SOURCE="/data/$LINE"
		DEST="$USBDRIVE/$SUBPATH"
		RCOMMAND='rsync -rtvh --modify-window 2 --delete --progress --include="*/" --include-from include-list --exclude="*" "'$SOURCE'" "'$DEST'"'
	fi
	echo $RCOMMAND
	eval $RCOMMAND
done <$INFILE
