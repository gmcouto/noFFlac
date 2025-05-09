#!/usr/bin/env bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input.m4a>"
    exit 1
fi

INPUT_FILE="$1"
FILENAME=$(basename "$INPUT_FILE" .m4a)
TEMP_DIR="temp"

# Create temp directory if it doesn't exist
mkdir -p "$TEMP_DIR"

# Find the first audio track ID and format
TRACK_INFO=$(mp4info "$INPUT_FILE" | grep -A10 "Track 1:")
TRACK_ID=1

if ! echo "$TRACK_INFO" | grep -q "type:.*Audio"; then
    echo "No audio track found in $INPUT_FILE" >&2
    exit 1
fi

# First unfragment the MP4
echo "Unfragmenting MP4 file..."
mp4fragment "$INPUT_FILE" "$TEMP_DIR/${FILENAME}_unfrag.m4a"

if [ $? -ne 0 ]; then
    echo "Error: Failed to unfragment the MP4 file"
    exit 1
fi

# Now extract the audio track using MP4Box
echo "Extracting audio track..."
MP4Box -raw 1 "$TEMP_DIR/${FILENAME}_unfrag.m4a" -out "$TEMP_DIR/$FILENAME.raw"

# Check if extraction was successful
if [ $? -eq 0 ]; then
    # Clean up temporary unfragmented file
    rm "$TEMP_DIR/${FILENAME}_unfrag.m4a"
    echo "Successfully extracted audio track to $TEMP_DIR/$FILENAME.raw"
else
    echo "Error: Failed to extract audio track"
    rm -f "$TEMP_DIR/${FILENAME}_unfrag.m4a"
    exit 1
fi 