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

create_md5sumfile() {
	OLD_PWD=$PWD
	cd $1
	echo $PWD
	UPDATE=0
	
	#if directory is empty
	if [ $(find -maxdepth 1 -type f -regex "^./[^\.].*" |wc -l) -eq 0 ]; then
		rm -f .md5sums
		cd $OLD_PWD
		return 0
	fi

	#determine if we should update
	if [ -f ".md5sums" ] && [ $(cat .md5sums | wc -l ) -gt 0 ]; then
		#try update the file
		#make some sanity check : is the first line correct? 
		SUCCESS=$(head -n 3 .md5sums |md5sum -c | wc -l)
		FILECOUNT=$(head -n 3  .md5sums |wc -l)
		FIND_COUNT_OF_FILES=$(find -maxdepth 1 -type f -regex "^./[^\.].*" |wc -l)
		FILE_COUNT_OF_FILES=$(cat .md5sums |wc -l)
		COUNT_NEW_FILES=$(find -maxdepth 1 -cnewer .md5sums -type f -regex "^./[^\.].*"|
		                   wc -l)
		TRACKED_FILES=$(($FIND_COUNT_OF_FILES - $COUNT_NEW_FILES))
		if [ $TRACKED_FILES  -gt $FILE_COUNT_OF_FILES  ]; then
			rm -f .md5sums
		elif [ ${SUCCESS} -gt $(($FILECOUNT - $SUCCESS)) ]; then
			UPDATE=1
		else
			rm -f .md5sums
		fi
	fi
	if [ $UPDATE -eq 1 ]; then
		#update
		echo "updating $PWD"
		for FILE in $(find -maxdepth 1 -cnewer .md5sums -type f -regex "^./[^\.].*" ); do
			if [ -n "$FILE" ] ; then
				if grep -q $FILE .md5sums; then
					#the file has been modified and is still present
					FIXEDFILE=$(echo $FILE | sed "s,\[,\\\[,; s,\],\\\],; s,\*,\\\*,; s,\.,\\\.,")
					sed -i "s,^.*$FIXEDFILE$,,g; /^$/d" .md5sums
				fi
				if [ -n "$VERBOSE"  ]
				then
					echo "${PWD}${FILE}"
				fi
				md5sum "$FILE"  >> .md5sums
			fi
		done
		for FILE in $(cut -d ' ' -f 2- .md5sums |sed "s: ::"); do
			if [ ! -f "$FILE" ]; then
				#delete ref : the file isn't anymore
				if [ -n "$VERBOSE"  ]
				then
					echo "${PWD}${FILE} isn't anymore R.I.P"
				fi
				FIXEDFILE=$(echo $FILE | sed "s,\[,\\\[,; s,\],\\\],; s,\*,\\\*,; s,\.,\\\.,")
				sed -i "s,^.*$FIXEDFILE$,,; /^$/d" .md5sums
			fi
		done
	else
		find -maxdepth 1  -type f  -regex "^./[^\.].*"		|
		inform               |
		(
		while read; do
			md5sum $REPLY  > .md5sums 
		done
		)
	fi
	cd  $OLD_PWD
}

create_finalfile() {
	rm -f $1
	for FILE in $(find $2 -name ".md5sums"); do
		DIR=${FILE/.md5sums/}
		cat $FILE | sed "s:\./:\./$DIR:" >> $1
	done
}
		

if [ "$1" == "--help" ] || [ $# -le 1 ] || [ ! -d $2 ]
then
	help
fi



IFS=$'\n'
if [ "$VERBOSE" != "0" ]
then 
	VERBOSE=1
fi

for DIR in $(find $2 -type d); do
	create_md5sumfile $DIR
done

create_finalfile $1 $2
