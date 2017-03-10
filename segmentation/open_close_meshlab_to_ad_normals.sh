#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "This script will use meshlabserver to open every .ply file in folder P1 (specified in the first param P1) and save them with normal and face flags"
	echo "Example: bash open_close_meshlab_to_ad_normals.sh ~/my_ply_dataset/" 	
  	exit 0
fi
for P in `ls -vd $1*.ply`;
do 	 
	meshlabserver -i $P -o $P -om vf vn ff fn 
done




