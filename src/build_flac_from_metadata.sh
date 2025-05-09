#!/usr/bin/env bash

# THIS MUST RECEIVE INPUT LIKE "Breakaway" (make it generic of course)
# And read Breakway.raw as the main flac audio track. No need to reencode.
# And read all metadata from temp/Breakaway_ with the metadata and cover art files
# Build a flac file with the track, metadata and cover art. The output file will be ./output/Breakaway.flac
# WITHOUT FFMPEG OR ANY CONVERSION
# KEEP THIS COMMENT HEADER TO NEVER LOSE THE MAIN PURPOSE OF THIS SCRIPT

# Check if track name is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a track name"
    echo "Usage: $0 <track_name>"
    exit 1
fi

TRACK_NAME="$1"
TEMP_DIR="temp"
OUTPUT_DIR="output"

# Check if required files exist
if [ ! -f "$TEMP_DIR/${TRACK_NAME}.raw" ]; then
    echo "Error: Raw audio file not found at $TEMP_DIR/${TRACK_NAME}.raw"
    exit 1
fi

if [ ! -f "$TEMP_DIR/${TRACK_NAME}_metadata.txt" ]; then
    echo "Error: Metadata file not found at $TEMP_DIR/${TRACK_NAME}_metadata.txt"
    exit 1
fi

if [ ! -f "$TEMP_DIR/${TRACK_NAME}_cover.jpg" ]; then
    echo "Error: Cover art not found at $TEMP_DIR/${TRACK_NAME}_cover.jpg"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Build the metaflac command with all metadata
METAFLAC_CMD="metaflac --import-picture-from=\"$TEMP_DIR/${TRACK_NAME}_cover.jpg\""

# Add metadata from file
METAFLAC_CMD="$METAFLAC_CMD --import-tags-from=\""$TEMP_DIR/${TRACK_NAME}_flac_metadata.txt"\""

# Copy the raw FLAC file to output
cp "$TEMP_DIR/${TRACK_NAME}.raw" "$OUTPUT_DIR/${TRACK_NAME}.flac"

# Apply metadata and cover art
eval "$METAFLAC_CMD \"$OUTPUT_DIR/${TRACK_NAME}.flac\""

# Clean up temporary metadata file
# rm "$TEMP_METADATA"

echo "Successfully created $OUTPUT_DIR/${TRACK_NAME}.flac with metadata and cover art"