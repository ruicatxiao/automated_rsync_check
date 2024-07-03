#!/bin/bash

# V2
# Print the usage
usage() {
    echo "Usage: $0 [RUN_FOLDER_NAME]"
    echo "If no RUN_NAME is provided, the script will list all available runs on NextSeq and exit."
    exit 1
}

# Modify here to change hard coded path

INPUT_BASE_PATH="/usr/local/illumina/runs/"
OUTPUT_BASE_PATH="/mnt/CHMI-Data/Data/"

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "No run name provided. Listing all possible runs:"
    ls -1 "$INPUT_BASE_PATH"
    exit 0
fi

# Check if the correct number of arguments are provided
if [ $# -ne 1 ]; then
    usage
fi


RUN_FOLDER_NAME=$1


INPUT_PATH="${INPUT_BASE_PATH}${RUN_FOLDER_NAME}/"



if [ ! -d "$INPUT_PATH" ]; then
    echo "Error: Input run '$INPUT_PATH' does not exist."
    exit 1
fi


DEST_PATH=""
for DIR in $(find "$OUTPUT_BASE_PATH" -type d -name "$RUN_FOLDER_NAME" -print); do
    DEST_PATH=$DIR
    break
done

if [ -z "$DEST_PATH" ]; then
    echo "Error: No destination folder found for $RUN_FOLDER_NAME"
    exit 1
fi

# Print the paths being used
echo "Input Path: $INPUT_PATH"
echo "Destination Path: $DEST_PATH"

# Get the current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Set the checksum file name
CHECKSUM_FILE="${OUTPUT_BASE_PATH}run${RUN_FOLDER_NAME}_checksum_${CURRENT_DATE}.txt"

# Run the rsync command with --dry-run and capture the output
rsync -avh --dry-run "$INPUT_PATH" "$DEST_PATH" --checksum --exclude="Logs/" \
| grep -E '^deleting|[^/]$|^$' > "$CHECKSUM_FILE"



echo "Checksum file created at $CHECKSUM_FILE"
