#!/bin/bash
declare Tab
IFS=$'\n'

for i in $(find -name "*md5sum.txt")
do
	echo "------------------------------"
	j=0
	k=0
	for FILE in $(cat "$i" | cut -d ' ' -f 2-|sed "s, ,,"); do
		if [ -f "$FILE" ]; then
			k=$((k+1))
			Tab[k]="$FILE"
			echo $((k)): "$FILE"
		fi
	done
	
	if [ $k -le 1 ]; then
		echo "only one file.... skipping"
	else
		echo
		echo "what file do you want to keep? write space separated list then <enter>"
		read ANSWER
		IFS=$' \t\n'
		for ANS in $ANSWER; do
			if [ "$ANS" == "n" ]; then
				echo "skipping"
				SKIP=1
				break
			elif [ $ANS  -gt  $k ]; then
				echo "wrong answer.... skipping"
				SKIP=1
				break
			else
				unset Tab[ANS]
			fi
		done
		IFS=$'\n'
		if [ "$SKIP" != "1" ]
		then
			for FILE in "${Tab[@]}"; do
				if [ -n "$FILE" ]; then
					rm "$FILE"
				fi
			done
		fi
	fi
	rm $i
done

echo "process empty dirs?"
read ANSWER
if [ "$ANSWER" == "y" ]; then 
	for DIR in $(find / -type d -empty 2>/dev/null)
	do
		rm -ir "$DIR"
	done
fi
