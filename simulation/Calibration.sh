#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "Script to run Gazebo calibration for every ptool inside every tool folder in a given root folder"
	echo "Params:"
	echo "        First param is the task name"
	echo "        Second param is folder containing all tools"
	echo "        Third param is number of trials for each ptool"
	echo "The script assumes your gazebo models are in ~/.gazebo/gazebo_models/ and that you have a structure of model folders corresponding to different tasks:"
	echo "        (e.g.)~/.gazebo/gazebo_models/hammering_training and/or ~/.gazebo/gazebo_models/lifting_pancake"
	echo ""
	echo "Example call: bash Calibration.sh hammering_nail calibration_dataset 5"
	echo "This will run 5 trials for each ptool inside each tool folder inside calibration_dataset for hammering nail task"
	exit 0
fi

TASK_NAME=$1
# exit if task name is not defined
if [ "$TASK_NAME" == "" ]
then
	echo "Please define the task name as the first parameter"
	exit
fi

CALIBRATION_FOLDER=$2
# exit if calibration name is not defined
if [ "$CALIBRATION_FOLDER" == "" ]
then
	echo "Please define the calibration folder as the second parameter"
	exit
fi

N_TRIALS=$3
# define beggining folder as 1 if not defined
if [ "$N_TRIALS" == "" ]
then
	echo "Please define the number of trials as the third parameter"
	exit
fi

ROOT_PATH="$HOME/.gazebo/gazebo_models/"
TASK_PATH="$ROOT_PATH$TASK_NAME"
START_TRIAL='start_trial'
END_TRIAL='end_trial'
GAZEBO_WORLD_FILE="$TASK_NAME.world"
OUTPUT_FILE="output_"$CALIBRATION_FOLDER".txt"
OUTPUT_EST_TIME_FILE="output_est_time_"$CALIBRATION_FOLDER".txt"

echo "Cding to task path: "$TASK_PATH
cd "$TASK_PATH"

# count number of folders
N_FOLDERS=0
for P in `ls -vd $TASK_PATH"/"$CALIBRATION_FOLDER/*`;
do 
	N_FOLDERS=$(($N_FOLDERS+1))
done

BEG=1
END=$N_FOLDERS

# define beggining folder as 1 if not defined
if [ "$BEG" == "" ]
then
	echo "WARNING: Initial folder not defined; begginning at 1"
	BEG=1
fi

# define end folder as N_FOLDERS if not defined
if [ "$END" == "" ]
then
	echo "WARNING: End folder not defined; ending at last folder"
	END=$N_FOLDERS	
fi
N_FOLDERS_TO_PROCESS=$(($(($END-$BEG))+1))

# define end as N_FOLDERS if the number of folders to process is larger than the number of folders
if (("$N_FOLDERS_TO_PROCESS" == "0"))
then
	echo "Could not find any folders to process at $TASK_PATH"/"$CALIBRATION_FOLDER/*"
	exit 0
fi

# define end as N_FOLDERS if the number of folders to process is larger than the number of folders
if (("$N_FOLDERS_TO_PROCESS" > $N_FOLDERS))
then
	echo "WARNING: Number of folders to process is larger than the number of folders; reverting to processing up to last folder"
	END=$N_FOLDERS
fi
N_FOLDERS_TO_PROCESS=$(($(($END-$BEG))+1))

echo "Number of tools to process: "$N_FOLDERS_TO_PROCESS
echo "Calibration Folder: "$CALIBRATION_FOLDER
echo "Gazebo World File: "$GAZEBO_WORLD_FILE
echo "Output File: "$OUTPUT_FILE

#read -p "Continue (y/n)?" CONTINUE
#case "$CONTINUE" in 
#  y|Y ) echo "Got it. Starting calibration...";; 
#  n|N ) echo "Got it. No calibration today :("
#		exit 0;;
#  * ) echo "Invalid option (no Humpty Dumpty, you need to choose: either y or n)"
#		exit 0;;
#esac

rm $OUTPUT_FILE
echo "task "$TASK_NAME >> $OUTPUT_FILE
echo "n_trials "$N_TRIALS >> $OUTPUT_FILE
IX_FOLDER=0
TOT_ELAPSED_TIME=0
IX_PROC_FOLDER=0;
echo ""
for TOOL_FOLDER in `ls -vd $CALIBRATION_FOLDER/*`;
do
	IX_FOLDER=$(($IX_FOLDER+1))
	if (("$IX_FOLDER" >= $BEG)) && (("$IX_FOLDER" <= $END))
	then
		IX_PROC_FOLDER=$(($IX_PROC_FOLDER+1))
		START_TIME=`date +%s`
		TOOL_FOLDER_PATH=$TASK_PATH"/"$TOOL_FOLDER
		echo "$TOOL_FOLDER"
		echo "tool "$TOOL_FOLDER >> $OUTPUT_FILE
		IX_PTOOL=0
		for PTOOL in `ls -vd $TOOL_FOLDER_PATH/*`;
		do
			rm -fr $TASK_PATH"/tool_"$TASK_NAME
			IX_PTOOL=$(($IX_PTOOL+1))
			echo "    Usage #$IX_PTOOL"
			cp -r $PTOOL"/" $TASK_PATH"/tool_"$TASK_NAME
			echo "ptool "$IX_PTOOL >> $OUTPUT_FILE		
			echo $START_TRIAL >> $OUTPUT_FILE
			for (( i=1; i<=$N_TRIALS; i++ ))
			do	
				echo "        Trial "$i	
				gzserver $GAZEBO_WORLD_FILE >> $OUTPUT_FILE
			done
			echo $END_TRIAL >> $OUTPUT_FILE	
		done		
		
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
		echo ""
		echo "Estimated time to finish (HH:MM): "$ESTIMATED_TIME
		echo ""
		rm $OUTPUT_EST_TIME_FILE
		echo $ESTIMATED_TIME >> $OUTPUT_EST_TIME_FILE
	fi
	if (("$IX_FOLDER" > $END)) 	
	then
		break
	fi
done
echo "end_calibration" >> $OUTPUT_FILE	
rm -r $TASK_PATH"/tool_"$TASK_NAME





