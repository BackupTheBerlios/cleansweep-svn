#!/bin/bash
#/***********************************************************************
#* copyright (c) 2004 MALET Jean-luc aka cityhunter
#* This program is free software; you can redistribute it and/or modify
#* it under the terms of the artistic license as published in the top source dir of the
#* package
#************************************************************************/

if [ -z "PARALLEL_PROCESSING" ]
then
PARALLEL_PROCESSING=0
fi

help() {
	echo "usage : md5dir.sh MD5SUMBASEfileNAME directories0"
	echo "set \$PARALLEL_PROCESSING >= 1 to activate parallel processing of dirs"
	echo "for exemple when doing the md5sum of dirs located on different discs"
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


i=$((0))
while [ -n "$1" ]
do
	i=$(($i+1))
	TEMP_MD5_SAME=$(echo $1| awk '{gsub("/","_"); printf("%s",$0);}').md5sums
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

