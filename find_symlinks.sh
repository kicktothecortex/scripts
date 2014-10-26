#!/bin/bash
IFS=$'\n'
prevLine=
printDir=

for line in `ls -lR $1 |grep "^l\|:$" ` ; do
        if [ -z $prevLine ] ; then
                prevLine=$line
        else
                if [ "${prevLine:$((1-2))}" == ":" ] && [ "${line:0:1}" == "l" ]; then
                        if [ -z $printDir ]; then
                                echo $prevLine
                                printDir=printed
                        fi
                        echo $line
                else
                        prevLine=$line
                        printDir=
                fi

        fi
done
