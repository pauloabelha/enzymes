#!/bin/bash
USER_SPEC_N_CORES=$1											# get user-specified number of cores
ROOT_FOLDER=$2												# get root folder for the whole process
MAX_N_CORES=`grep -c ^processor /proc/cpuinfo`  							# set max number of cores as the actual number of cores in the machine
MAX_N_CORES=$(( $USER_SPEC_N_CORES < $MAX_N_CORES ? $USER_SPEC_N_CORES : $MAX_N_CORES )) 		# get number of cores to use as min(input number of cores,number of cores in the machine)
N_CORES=$(( 1 > $MAX_N_CORES ? 1 : $MAX_N_CORES )) 							# get at least one core to use
N_PCLS_ROOT_FOLDER=0
for P in `ls -vd $ROOT_FOLDER*.ply`;									# get total number of pcls in root folder
do
	((N_PCLS_ROOT_FOLDER=N_PCLS_ROOT_FOLDER+1))
done
N_PCLS_PER_CORE=$(($N_PCLS_ROOT_FOLDER/$N_CORES))							# get number of pcls for each core (may be a noninteger division - see below)
i=0
for P in `ls -vd $ROOT_FOLDER*.ply`;									# partition the pcls in root folder to copy a subset into each folder
do
	RESP_CORE=$(( $(( i / $N_PCLS_PER_CORE )) + 1 ))						# get the core number responsible for the current pcl
	RESP_CORE=$(( $RESP_CORE < $N_CORES ? $RESP_CORE : $N_CORES )) 					# needed to assign to last core the pcls left because of noninteger  n_pcls / n_cores		
	cp $P $ROOT_FOLDER"autosegmentation_core_"$RESP_CORE/						# copy the pcl
	((i=i+1))
done
for CORE_NUM in `seq 1 $N_CORES`;									# start one task for each core in its specific folders
do
	FOLDER_CORE_NAME=$ROOT_FOLDER$"autosegmentation_core_"$CORE_NUM					# get the core's folder name
	mkdir $FOLDER_CORE_NAME										# create the core's folder
	taskset --cpu-list `expr $CORE_NUM - 1`  bash auto_segmentation.sh $FOLDER_CORE_NAME/ $3 $4 &		# start task for the core in the folder
done


