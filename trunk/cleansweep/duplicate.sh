#!/bin/bash 
#/***********************************************************************
#* copyright (c) 2004 MALET Jean-luc aka cityhunter
#* This program is free software; you can redistribute it and/or modify
#* it under the terms of the artistic license as published in the top source dir of the
#* package
#************************************************************************/
while echo ""; do
	read FROM;
	read TO; 
	cp "$FROM" "$TO"
done
