#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "Script to delete all files of a given type inside each subfolder of a given root folder"
	echo "First param: root folder"
	echo "Second param: file type"
	exit 0
fi

ROOT_FOLDER=$1
FILE_TYPE=$2

if [ "$ROOT_FOLDER" == "" ]
then
	echo "Please define a root folder as first param (see --help)"
	exit
fi

if [ "$FILE_TYPE" == "" ]
then
	echo "Please define a file type as second param (see --help)"
	exit
fi

for P in `ls -vd $ROOT_FOLDER/*/`;
do
	rm $P"tool."$FILE_TYPE
done
