#!/bin/bash


if [ "$1" == "--help" ]; then
	echo "This script will run a demo for a task (only one param which is the task name)"
	echo "Example: bash demo_task_simulation.sh hammering_nail"
	exit 0
fi

TASK_NAME=$1

echo "Running demo for task "$TASK_NAME

ROOT_PATH="$HOME/.gazebo/gazebo_models/"
TASK_PATH="$ROOT_PATH$TASK_NAME"
TOOL_FOLDER="tool_$TASK_NAME"
GAZEBO_WORLD_FILE="$TASK_NAME.world"
OUTPUT_FILE="demo_results.txt"
DEMO_TOOL_FOLDER="demo_tool"

cd $TASK_PATH
rm $OUTPUT_FILE
echo "Removed previous output file "$OUTPUT_FILE

cp -r $DEMO_TOOL_FOLDER $TOOL_FOLDER/
echo "Demo tool found"
echo "Starting simulation..."

gazebo -u $GAZEBO_WORLD_FILE >> $OUTPUT_FILE

rm -r $TOOL_FOLDER

echo "Demo finished"
echo "Check the demo log file at "$TASK_PATH"/"$OUTPUT_FILE
