#!/bin/bash -x
while echo ""; do
	read FROM;
	read TO; 
	cp "$FROM" "$TO"
done