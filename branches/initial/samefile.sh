#!/bin/bash

TEMP_MD5_SAME_ref="/tmp/temp_md5_same.md5"
if [ -z "$TEMP_MD5_SAME" ] 
then
	TEMP_MD5_SAME=$TEMP_MD5_SAME_ref
fi
if [ -z "$VERBOSE" ]
then
	VERBOSE=0
fi
PARALLEL_PROCESSING=0

process_dir() {
	OLD_PWD="$PWD1"
	echo "processing Directories $1"
	cd "$1"
	find -type f |
	while read FILE
	do
		if [ $VERBOSE -ge 1 ]
		then
			echo "$FILE"
		fi
		md5sum -b "$FILE" >> "$TEMP_MD5_SAME"	
	done
	sed -i "s:\*\.:\*:" "$TEMP_MD5_SAME"
	cd "$OLD_PWD1"
}

help() {
	echo "usage : samefile.sh [-f location in_md5file]"
	echo "                     multiple -f allowed, at least one ^_^"
	echo "                     -f : 'location' is the directory where the disk "
	echo "                          containing files is mounted"
	echo "         this allow to reuse md5files created on different systems"
	echo "              example :"
	echo "                 XXX create a md5file for dir /home/common/trailers"
	echo "                 YYY want to know about new files of XXX"
	echo "                 YYY mount the disk of XXX into /mnt"
	echo "                 then issue samefile.sh -d localdir -f /mnt/home/common/trailers /mnt/md5file"
	echo "                 YYY then get all file in common or different.."
	echo "files are created in current directoy : "
	echo "      common_*_md5sum.txt : common md5sums one per md5sum"
	echo "      common_*_name.txt   : common name    one per name"
	echo "      unique_files.txt    : file containing files not shared among comparison"
	exit
}

if [ "$1" == "--help" ] || [ $# -le 1 ]
then
	help
fi

if [ -f "$TEMP_MD5_SAME" ]; then
	rm -f "$TEMP_MD5_SAME"
	touch "$TEMP_MD5_SAME"
fi

if [ "$PWD1" == "" ]
then
	export PWD1=$PWD
fi

while  [  -n  "$1"  ];  
do
	if  echo  "" $1  |  grep  -q  "^ -";  then
      case  $1  in
			-f) cat "$3"|sed  "s:\*/:\*$2/:" >> "$TEMP_MD5_SAME"
				shift 3 ;;
          *)  help ;;
      esac
   else
		shift
		shift
	fi
done

if [ -f /tmp/unique_files.txt ]; then
	rm -f /tmp/unique_files.txt
fi
touch /tmp/unique_files.txt

echo "process md5sums duplication"
cut -d ' ' -f 1 "$TEMP_MD5_SAME" |sort |uniq |
while read i 
do
	grep $i "$TEMP_MD5_SAME" |sort |uniq >"commom_${i}_md5sum.txt"
	if [ $(wc -l "commom_${i}_md5sum.txt" |cut -d ' ' -f 1 ) -le 1 ]
	then 
		cat "commom_${i}_md5sum.txt" >> /tmp/unique_files.txt
		rm -f "commom_${i}_md5sum.txt"
	fi
done



if [ -f unique_files.txt ]; then
	rm -i unique_files.txt
fi
touch unique_files.txt

cut -d ' ' -f 2- /tmp/unique_files.txt |sort |uniq >unique_files.txt
rm -f /tmp/unique_files.txt

echo "process filename duplication"
cut -d ' ' -f 2- "$TEMP_MD5_SAME"|sed "s:/:_:g" |sort |uniq |
while read FILESNAMES
do
	grep -F "$FILESNAMES" "$TEMP_MD5_SAME" |sort |uniq > "commom_${FILESNAMES}_name.txt"
	if [ $(wc -l "commom_${FILESNAMES}_name.txt" |cut -d ' ' -f 1 ) -le 1 ] ||
		[ $(cut -d ' ' -f 2- "commom_${FILESNAMES}_name.txt"|sed "s:^\*.*/::" |sort |uniq | wc -w ) -gt 1 ]
	then 
		#cat "commom_${FILESNAMES}_name.txt"
		rm -f "commom_${FILESNAMES}_name.txt"
	elif [ $(cut -d ' ' -f 1 "commom_${FILESNAMES}_name.txt" |sort |uniq |wc -w) -le 1 ]
	then
			rm -f "commom_${FILESNAMES}_name.txt"
	fi
done
rm -f "$TEMP_MD5_SAME"
