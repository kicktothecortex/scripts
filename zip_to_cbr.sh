#!/bin/bash

## Script to convert from zip file to cbr for comic readers

FILE=$1
ZIPFILE=`readlink -f "$1"`
TEMPDIR="/tmp"
ISSUE="${FILE%%.*}"
ISSUEDIR="temp_$ISSUE"
ORIGINALDIR=`pwd`

cd "$TEMPDIR"
mkdir "$ISSUEDIR"
cd "$ISSUEDIR"
unzip -d . "$ZIPFILE"
cd "$TEMPDIR"
rar a -ep "$ISSUE.cbr" "$ISSUEDIR"
mv -v "$ISSUE.cbr" "$ORIGINALDIR"
rm -rfv "$ISSUEDIR"
#rm -rfv "$ZIPFILE"
