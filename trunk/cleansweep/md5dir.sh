#!/bin/sh
#/***********************************************************************
#* copyright (c) 2004 MALET Jean-luc aka cityhunter
#* This program is free software; you can redistribute it and/or modify
#* it under the terms of the artistic license as published in the top source dir of the
#* package
#************************************************************************/

help() {
	echo "usage : md5dir.sh MD5SUMfile directory"
	exit
}


inform()  {

  if    [  -n  "$VERBOSE"  ]
  then  tee  /dev/stderr
  else  cat  -
  fi

}

if [ "$1" == "--help" ] || [ $# -le 1 ] || [ ! -d $2 ]
then
	help
fi



IFS=$'\n'
SAME=0
DIFF=0
UPDATE=0
if [ "$VERBOSE" != "0" ]
then 
	VERBOSE=1
fi

if [ -f "$1" ]; then
#try update the file
#make some sanity check : is the first line correct? 
	for FILE in $(head -n 3 $1 |cut -d ' ' -f 2-|sed "s, \./,$2/,"); do
		MD5SUM=$(md5sum -b "$FILE" | cut -d ' ' -f 1)
		if [ -n "$MD5SUM" ] && grep -q $MD5SUM "$1" ; then
			SAME=$((SAME+1))
		else
			DIFF=$((DIFF+1))
		fi
	done
	if [ $((SAME)) -gt $((DIFF)) ]; then
		UPDATE=1
	else
		rm -f "$1"
		touch "$1"
	fi
else
	if [ -f "$1" ]; then
		rm -f "$1"
	fi
	touch "$1"
fi

if [ $UPDATE -eq 1 ]; then
	#update
	echo "updating"
	for FILE in $(find $2 -cnewer $1 -type f | sed "s,$2,,"); do
		if [ -n "$FILE" ] ; then
			if grep -q $FILE $1; then
				FIXEDFILE=$(echo $FILE | sed "s,\[,\\\[,; s,\],\\\],; s,\*,\\\*,; s,\.,\\\.,")
				sed -i "s,^.*$FIXEDFILE$,,g; /^$/d" "$1"
			fi
			if [ -n "$VERBOSE"  ]
			then
				echo "$FILE"
			fi
			md5sum "$2/$FILE" |sed "s,$2/,./," >>"$1"
		fi
	done
	for FILE in $(cut -d ' ' -f 2- $1 |sed "s: ::"); do
		if [ ! -f "$2/$FILE" ]; then
			#delete ref : the file isn't anymore
			if [ -n "$VERBOSE"  ]
			then
				echo "$FILE isn't anymore R.I.P"
			fi
			FIXEDFILE=$(echo $FILE | sed "s,\[,\\\[,; s,\],\\\],; s,\*,\\\*,; s,\.,\\\.,")
			sed -i "s,^.*$FIXEDFILE$,,; /^$/d" "$1"
		fi
	done
else
	OLD_PWD="$PWD"
	echo "processing Directories $2"
	cd "$2"
	
	find  -type f  		|
	inform               |
	sed  's: :\\ :g
			s:":\\":g'     |
	sed  "s:':\\\':g"    |
	xargs -l64 md5sum  >   "$OLD_PWD/$1"

	cd "$OLD_PWD"
fi
