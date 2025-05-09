#!/usr/bin/env bash

# Given an input m4a file, for example "Breakaway.mp4"
# Extract the cover art and save it as "temp/Breakaway_cover.[ext]" (keep the original file type extension)
# The tool FFMPEG MUST NOT BE USED at all, for any reason. You can use mediainfo, MP4Box, or any other dependency you feel like installing (update setup files if necessary).
# KEEP THIS COMMENT HEADER TO NEVER LOSE THE MAIN PURPOSE OF THIS SCRIPT

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file.m4a>"
    exit 1
fi

# Get input file
input_file="$1"
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' does not exist"
    exit 1
fi

# Get base name without extension
base_name=$(basename "$input_file" .m4a)
output_dir="temp"

# Create temp directory if it doesn't exist
mkdir -p "$output_dir"

echo "Extracting cover art from $input_file..."

# First check if the file has cover art using mediainfo
if ! mediainfo --Inform="General;%Cover%" "$input_file" | grep -q "Yes"; then
    echo "No cover art found in file"
    exit 0
fi

# Get cover art format using mediainfo
cover_format=$(mediainfo --Inform="General;%Cover_Type%" "$input_file" | tr '[:upper:]' '[:lower:]')
case "$cover_format" in
    "jpg" | "jpeg")
        extension="jpg"
        ;;
    "png")
        extension="png"
        ;;
    *)
        # Default to jpg if format is unknown
        extension="jpg"
        ;;
esac

# Extract cover art using MP4Box
MP4Box -dump-cover "$input_file" > /dev/null 2>&1

# Check if extraction was successful and move to correct location
if [ -f "${base_name}.jpg" ]; then
    mv "${base_name}.jpg" "$output_dir/${base_name}_cover.$extension"
    echo "Cover art successfully extracted to: $output_dir/${base_name}_cover.$extension"
else
    echo "Failed to extract cover art"
    exit 1
fi
