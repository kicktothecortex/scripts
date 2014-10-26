#!/bin/bash

## Script to download issues of Naruto Manga from ColorKage.com

ISSUE=$1
ADDR="http://colorkage.com/read/titles/Naruto/$ISSUE/"
#ADDR="http://mangajoy.com/wp-content/manga/5100/$ISSUE/"
TEMPDIR="/tmp"
ISSUEDIR="temp_$ISSUE"
ORIGINALDIR=`pwd`
ISSUENAME="Naruto - $ISSUE.cbr"

INCLUDE="jpeg,jpg,gif,png"
EXCLUDE="back.gif,blank.gif,image2.gif,unknown.gif"

cd "$TEMPDIR"
mkdir "$ISSUEDIR"
cd "$ISSUEDIR"
wget -q -nd -r -l 1 -A $INCLUDE -R $EXCLUDE -e robots=off "$ADDR"
cd "$TEMPDIR"
rar a -ep "$ISSUENAME" "$ISSUEDIR"
mv -v "$ISSUENAME" "$ORIGINALDIR"
rm -rf "$ISSUEDIR"
