#!/bin/bash

# Initialize debug flag
DEBUG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -debug)
            DEBUG=true
            shift
            ;;
        *)
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 [-debug] <input_file.m4a>"
    exit 1
fi

# Extract the input file name without extension
INPUT_NAME="${INPUT_FILE%.*}"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Check if the file is an M4A file
if [[ "${INPUT_FILE##*.}" != "m4a" ]]; then
    echo "Error: Input file must be an M4A file"
    exit 1
fi

# Create necessary directories
mkdir -p temp output

# Function to cleanup temp directory
cleanup() {
    if [ "$DEBUG" = false ]; then
        echo "Cleaning up temporary files..."
        rm -rf temp/*
    else
        echo "Debug mode: Keeping temporary files in temp/ directory"
    fi
}

# Set up trap to ensure cleanup happens even if script fails
trap cleanup EXIT

# Step 1: Extract metadata from M4A file
echo "Extracting metadata from M4A file..."
./src/extract_m4a_metadata.sh "$INPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract metadata"
    exit 1
fi

# Step 2: Convert metadata to FLAC format
echo "Converting metadata to FLAC format..."
./src/convert_metadata.sh "temp/${INPUT_NAME}_metadata.txt" "temp/${INPUT_NAME}_flac_metadata.txt"
if [ $? -ne 0 ]; then
    echo "Error: Failed to convert metadata to FLAC format"
    exit 1
fi

# Step 3: Extract raw audio track
echo "Extracting raw audio track..."
./src/extract_m4a_raw_audio_track.sh "$INPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract raw audio track"
    exit 1
fi

# Step 4: Extract cover art
echo "Extracting cover art..."
./src/extract_m4a_cover.sh "$INPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract cover art"
    exit 1
fi

# Step 5: Build FLAC file with metadata
echo "Converting to FLAC and embedding metadata..."
./src/build_flac_from_metadata.sh "$INPUT_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to build FLAC file"
    exit 1
fi

echo "Conversion completed successfully!"
echo "Output file: output/${INPUT_NAME}.flac" 