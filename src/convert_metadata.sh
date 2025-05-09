#!/bin/bash

# This script receives two parameters: inputFile and outputFile
# Example:
# Input is a file name 'temp/Breakaway_metadata.txt'
# Output is a file name 'temp/Breakaway_flac_metadata.txt'
# This script contains two variables easy to maintain:
# 1. BLACKLISTED_METADATA_KEYS: a list of metadata keys to be removed
# 2. METADATA_MAP: a mapping of M4A metadata keys to FLAC metadata keys
# The script will read the input file, remove the blacklisted keys and map the remaining keys to the FLAC metadata keys.
# Then it will output the result to the output file.
# Additional Context:
# - The input file is a text file with metadata in the format of key=value
# - The output file will be a text file with metadata in the format of key=value
# - BLACKLISTED_METADATA_KEYS must contain keys related to mp4 tracks and encoding (not useful for the users and music listeners)
# - METADATA_MAP must cover all keys that exist in FLAC files but have different names in M4A files
# - Keys in the input file that are not in BLACKLISTED_METADATA_KEYS or METADATA_MAP will be added as is to the output file
# - The script will output the result to the output file.

# Keep this comment header to never lose the main purpose of this script

# Check if input and output files are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <inputFile> <outputFile>"
    exit 1
fi

inputFile="$1"
outputFile="$2"

# Check if input file exists
if [ ! -f "$inputFile" ]; then
    echo "Error: Input file '$inputFile' does not exist"
    exit 1
fi

# Define blacklisted metadata keys (technical/encoding related keys)
BLACKLISTED_METADATA_KEYS=(
    "AUDIOCOUNT"
    "FILEEXTENSION"
    "FORMAT"
    "CODECID"
    "CODECID_COMPATIBLE"
    "FILESIZE"
    "OVERALLBITRATE_MODE"
    "OVERALLBITRATE"
    "STREAMSIZE"
    "HEADERSIZE"
    "DATASIZE"
    "FOOTERSIZE"
    "ISSTREAMABLE"
    "STREAMORDER"
    "ID"
    "BITRATE_MODE"
    "BITRATE"
    "CHANNELPOSITIONS"
    "CHANNELLAYOUT"
    "SAMPLINGCOUNT"
    "FRAMECOUNT"
    "COMPRESSION_MODE"
    "EXTRA"
    "FILE_MODIFIED_DATE"
    "FILE_MODIFIED_DATE_LOCAL"

)

# Define metadata mapping (M4A to FLAC)
# Using a simpler approach without associative arrays
map_key() {
    case "$1" in
        "TITLE") echo "TITLE" ;;
        "ALBUM") echo "ALBUM" ;;
        "ALBUM_PERFORMER") echo "ALBUMARTIST" ;;
        "PART_POSITION") echo "DISCNUMBER" ;;
        "PART_POSITION_TOTAL") echo "TOTALDISCS" ;;
        "TRACK") echo "TRACKNAME" ;;
        "TRACK_POSITION") echo "TRACKNUMBER" ;;
        "TRACK_POSITION_TOTAL") echo "TOTALTRACKS" ;;
        "PERFORMER") echo "ARTIST" ;;
        "COMPOSER") echo "COMPOSER" ;;
        "PRODUCER") echo "PRODUCER" ;;
        "RECORDED_DATE") echo "DATE" ;;
        "ISRC") echo "ISRC" ;;
        "COPYRIGHT") echo "COPYRIGHT" ;;
        "LYRICS") echo "LYRICS" ;;
        "RATING") echo "RATING" ;;
        *) echo "$1" ;;
    esac
}

# Create or clear the output file
> "$outputFile"

# Process the input file
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Skip lines starting with @
    [[ "$line" =~ ^@ ]] && continue
    
    # Split the line into key and value
    key="${line%%=*}"
    value="${line#*=}"
    
    # Skip blacklisted keys
    skip=0
    for blacklisted in "${BLACKLISTED_METADATA_KEYS[@]}"; do
        if [[ "$key" == "$blacklisted" ]]; then
            skip=1
            break
        fi
    done
    [[ $skip -eq 1 ]] && continue
    
    # Map the key and write to output
    mapped_key=$(map_key "$key")
    echo "${mapped_key}=${value}" >> "$outputFile"
done < "$inputFile"

echo "Metadata conversion completed. Output written to '$outputFile'"