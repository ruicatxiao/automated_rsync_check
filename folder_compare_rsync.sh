#!/bin/bash

# V
# Function to print the usage
usage() {
    echo "Usage: $0 RUN_FOLDER_NAME"
    echo "Example: $0 240412_VH00824_185_AACHLTGHV"
    exit 1
}

# Check if the correct number of arguments are provided
if [ $# -ne 1 ]; then
    usage
fi

# Assigning the argument to variable
RUN_FOLDER_NAME=$1

# Fixed input and output base paths
INPUT_BASE_PATH="/usr/local/illumina/runs/"
OUTPUT_BASE_PATH="/mnt/CHMI-Data/Data/"

# Construct the full input path
INPUT_PATH="${INPUT_BASE_PATH}${RUN_FOLDER_NAME}/"

# Check if the input directory exists
if [ ! -d "$INPUT_PATH" ]; then
    echo "Error: Input path '$INPUT_PATH' does not exist."
    exit 1
fi

# Find the destination path
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

# Set the checksum file name
CHECKSUM_FILE="${OUTPUT_BASE_PATH}run${RUN_FOLDER_NAME}_checksum.txt"

# Run the rsync command with --dry-run and capture the output
rsync -avh --dry-run "$INPUT_PATH" "$DEST_PATH" --checksum --exclude="Logs/" \
| grep -E '^deleting|[^/]$|^$' > "$CHECKSUM_FILE"

# Print completion message
echo "Checksum file created at $CHECKSUM_FILE"
