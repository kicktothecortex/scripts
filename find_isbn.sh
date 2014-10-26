#!/bin/bash

# for FILE in *; do echo "$FILE"; lesspipe "$FILE" | head -n1000 | grep -i isbn; done

for FILE in *.pdf; do
	echo "$FILE:";
	#eval $(lesspipe "$FILE" | head -n1000 | grep -i isbn);
	#lesspipe "$FILE" | head -n1000 | egrep -e '(97(8|9))?\d{9}(\d|X)';
	lesspipe "$FILE" | head -n1000 | egrep -i isbn | cut -d " " -f 2 | sed 's/-//g'
	#lesspipe "$FILE" | head -n1000 | grep -i isbn
	#echo "Variables:";
done
