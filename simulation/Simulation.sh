#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "Script to run Gazebo simulation for every model in a given folder (or optionally for a given range of folders)"
	echo "Mandatory params: first param is the folder in which all the models are; second param is the task name; and third param is the number fo trialsfor each model"
	echo "The script assumes your gazebo models are in ~/.gazebo/gazebo_models/ and that you have a structure of model folders corresponding to different tasks:"
	echo "        Example: ~/.gazebo/gazebo_models/hammering_training and/or ~/.gazebo/gazebo_models/lifting_pancake"
	echo "Optional params: fourth for a beggining and fifth for an ending folder number"
	echo "Example: bash Simulation.sh training hammering_nail 5 3 27"
	echo "This will run 5 trials for each of the model in between 3 and 27 (inclusive) - considering an alphabetic order of the folders"
	exit 0
fi

SIMULATION_FOLDER=$1
TASK_NAME=$2
# exit if task name is not defined
if [ "$TASK_NAME" == "" ]
then
	echo "Please define the task name as the first parameter"
	exit
fi
N_TRIALS=$3
# define beggining folder as 1 if not defined
if [ "$N_TRIALS" == "" ]
then
	echo "Please define the number of trials as the second parameter"
	exit
fi

BEG=$4
END=$5

ROOT_PATH="$HOME/.gazebo/gazebo_models/"
TASK_PATH="$ROOT_PATH$TASK_NAME"
TOOL_FOLDER="tool_$TASK_NAME"
START_TRIAL='start_trial'
END_TRIAL='end_trial'
GAZEBO_WORLD_FILE="$TASK_NAME.world"
OUTPUT_FILE="output_"$SIMULATION_FOLDER".txt"
OUTPUT_EST_TIME_FILE="output_est_time_"$SIMULATION_FOLDER".txt"

# define beggining folder as 1 if not defined
if [ "$BEG" == "" ]
then
	echo "WARNING: Initial folder not defined; begginning at 1"
	BEG=1
fi

echo "Cding to task path: "$TASK_PATH
cd "$TASK_PATH"

# count number of folders
N_FOLDERS=0
for P in `ls -vd $SIMULATION_FOLDER/*`;
do 
	N_FOLDERS=$(($N_FOLDERS+1))
done

# define end folder as N_FOLDERS if not defined
if [ "$END" == "" ]
then
	echo "WARNING: End folder not defined; ending at last folder"
	END=$N_FOLDERS	
fi
N_FOLDERS_TO_PROCESS=$(($(($END-$BEG))+1))

# define end as N_FOLDERS if the number of folders to process is larger than the number of folders
if (("$N_FOLDERS_TO_PROCESS" > $N_FOLDERS))
then
	echo "WARNING: Number of folders to process is larger than the number of folders; reverting to processing up to last folder"
	END=$N_FOLDERS
fi
N_FOLDERS_TO_PROCESS=$(($(($END-$BEG))+1))


echo "Beggining: "$BEG
echo "End: "$END
echo "Number of folders to process: "$N_FOLDERS_TO_PROCESS
echo "Gazebo Simulation Folder: "$SIMULATION_FOLDER
echo "Gazebo World File: "$GAZEBO_WORLD_FILE
echo "Output File: "$OUTPUT_FILE

rm $OUTPUT_FILE

echo "task $TASK_NAME" >> $OUTPUT_FILE
echo "n_trials $N_TRIALS" >> $OUTPUT_FILE

IX_FOLDER=0
TOT_ELAPSED_TIME=0
IX_PROC_FOLDER=0;
for P in `ls -vd $SIMULATION_FOLDER/*`;
do
	IX_FOLDER=$(($IX_FOLDER+1))
	if (("$IX_FOLDER" >= $BEG)) && (("$IX_FOLDER" <= $END))
	then
		IX_PROC_FOLDER=$(($IX_PROC_FOLDER+1))
		START_TIME=`date +%s`
		rm -r $TOOL_FOLDER	
		echo "Current tool folder being trained: "$TASK_PATH"/"$P
		cp -r $P $TOOL_FOLDER
		echo $START_TRIAL >> " " >> IX_FOLDER >> $OUTPUT_FILE
		for (( i=1; i<=$N_TRIALS; i++ ))
		do	
			echo "  Trial "$i	
			gzserver $GAZEBO_WORLD_FILE >> $OUTPUT_FILE	
		done
		echo $END_TRIAL >> $OUTPUT_FILE		
		
		# calculate and echo estimated time to finish in date format (HH:MM)
		END_TIME=`date +%s`
		ELAPSED_TIME=$(( $END_TIME - $START_TIME ))
		TOT_ELAPSED_TIME=$(($TOT_ELAPSED_TIME+$ELAPSED_TIME))
		AVG_ELAPSED_TIME=$(($TOT_ELAPSED_TIME/$IX_PROC_FOLDER))
		N_REMAINING_FOLDERS=$(($N_FOLDERS_TO_PROCESS-$IX_PROC_FOLDER))
		ESTIMATED_TIME_SEC=$(($AVG_ELAPSED_TIME*$N_REMAINING_FOLDERS))
		ESTIMATED_TIME_HRS=$(($ESTIMATED_TIME_SEC/3600))
		REST=$(($ESTIMATED_TIME_HRS*3600))
		REST=$(($ESTIMATED_TIME_SEC-$REST))
		ESTIMATED_TIME_MIN=$(($REST/60))
		REST=$(($ESTIMATED_TIME_HRS+$ESTIMATED_TIME_MIN))
		REST=$(($ESTIMATED_TIME_SEC-$REST))	
		
		ESTIMATED_TIME=$(printf "%d:%02d" $ESTIMATED_TIME_HRS $ESTIMATED_TIME_MIN)
		echo "Estimated time to finish (HH:MM): "$ESTIMATED_TIME
		rm $OUTPUT_EST_TIME_FILE
		echo $ESTIMATED_TIME >> $OUTPUT_EST_TIME_FILE
	fi
	if (("$IX_FOLDER" > $END)) 	
	then
		break
	fi
done
rm -r $TOOL_FOLDER





