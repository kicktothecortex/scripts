#!/bin/bash
#
# Fetches news from predefined Calibre 'recipes'

#NEWSDIR="/media/roms_n_such/Books/test/"
NEWSDIR="/home/digix/news/"
RECIPEFILE="subscriptions"
OUTEXT="txt"

cd $NEWSDIR

echo
while read LINE
do
	echo "
############################################
###### DOWNLOADING $LINE
############################################
"
	RECIPE="$LINE.recipe"
	OUTNAME="$LINE.$OUTEXT"
	echo "ebook-convert '$RECIPE' '$OUTNAME'"
	ebook-convert "$RECIPE" ".$OUTEXT"
done <$RECIPEFILE
