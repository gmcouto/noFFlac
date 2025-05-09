#!/bin/bash

# The purpose of this script is to extract all existing metadata from an m4a file
# This should include the track name, artist, album, year, genre. Except for the cover art.
# Composer, Dates, Lyrics, Disc Numbers, Codes, etc.
# The input of this script is the name of the track with the extension .m4a
# The output should be in the temp/ directory
# The for the input "Breakaways.mp4" the output files should be named "temp/Breakaways_metadata.txt"
# The output metadata should be easily parseable to be used by the build_flac_from_metadata.sh script
# The tool FFMPEG should not be used at all. You can use mediainfo, MP4Tool, etc.
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
metadata_file="$output_dir/${base_name}_metadata.txt"

# Create temp directory if it doesn't exist
mkdir -p "$output_dir"

echo "Extracting metadata from $input_file..."

# Function to clean and format field names
clean_field_name() {
    # Convert to uppercase
    # Replace spaces and special characters with underscores
    # Remove any remaining special characters
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr ' ' '_' | tr -cd '[:alnum:]_'
}

# Function to clean field values
clean_field_value() {
    # Remove any null characters and trim whitespace
    echo "$1" | tr -d '\0' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Extract all metadata using mediainfo in a parseable format
{
    # Get all metadata in a parseable format
    mediainfo --Output=JSON "$input_file" | jq -r '
        .media.track[] | 
        to_entries[] | 
        select(.value != null and .value != "") | 
        select(.key != "Cover") |
        "\(.key | ascii_upcase | gsub(" "; "_"))=\(.value)"
    '
} > "$metadata_file"

echo "Metadata extraction complete. Output saved to $metadata_file"