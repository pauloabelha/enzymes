#!/bin/bash

if [ "$1" == "--help" ]; then
	echo " ********************* HELP for pcl_batch_conv *********************" 	
	echo "Script to call a given binary o run on all files of a given extension in a folder"
	echo "First param: pcl library binary to be applied"
	echo "Folder with files"
	echo "Example:"
	echo "./pcl_batch_conv pcl_pcd2ply ~/my_data/" 
	echo ""
	echo "This script will create a subfodler inside folder to hold the converted pcls"
	echo " *******************************************************************"
	exit 0
fi

PCL_BIN=$1
ROOT_FOLDER=$2
OUT_EXT=${PCL_BIN:${#PCL_BIN}-3:${#PCL_BIN}-1}

if [ "$PCL_BIN" == "" ]
then
	echo "Please define the pcl binary to be applied"
	echo ""
	bash pcl_batch_conv.sh --help
	exit 0
fi
if [ "$ROOT_FOLDER" == "" ]
then
	echo "Please define the root folder with the files"
	echo ""
	bash pcl_batch_conv.sh --help
	exit 0
fi

OUT_FOLDER=$ROOT_FOLDER/
rm -r $OUT_FOLDER
mkdir $OUT_FOLDER
for file in $ROOT_FOLDER*; do
  file_in=${file##*/}
  file_out=${file_in:0:${#file_in}-4}.$OUT_EXT
  echo $PCL_BIN $ROOT_FOLDER/$file_in $OUT_FOLDER/$file_out
  $PCL_BIN $ROOT_FOLDER/$file_in $OUT_FOLDER/$file_out
  $PCL_BIN $ROOT_FOLDER/$file_in $OUT_FOLDER/$file_out
  meshlabserver -i $OUT_FOLDER/$file_out -o $OUT_FOLDER/$file_out -om vn vf fn fc ff
done





