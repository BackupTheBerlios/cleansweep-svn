#!/bin/bash

if [ -z "PARALLEL_PROCESSING" ]
then
PARALLEL_PROCESSING=0
fi

help() {
	echo "usage : md5dir.sh MD5SUMBASEfileNAME directories"
	exit
}

if [ "$1" == "--help" ] || [ $# -le 1 ] || [ "$1" == "-h" ]
then
	help
fi

for i in "$@"; do 
	if [ "$i" != "$1" ]; then
		if [ ! -d $i ]; then
			help
		fi
	fi
done


BASENAME=$1 
shift 
#faire plus intelligent :recup le nom du dernier rep ou remplacer / par -
i=$((0))
while [ -n "$1" ]
do
	i=$(($i+1))
	export TEMP_MD5_SAME=$BASENAME--$i
	if [ -f "$TEMP_MD5_SAME" ]; then
		rm -i "$TEMP_MD5_SAME"
	fi
	touch "$TEMP_MD5_SAME"
	if [ -n "$PARALLEL_PROCESSING" ] && [ $PARALLEL_PROCESSING -ge 1 ]
	then
		md5dir.sh "$TEMP_MD5_SAME" "$1" &
	else
		md5dir.sh "$TEMP_MD5_SAME" "$1" 
	fi
	shift
done

