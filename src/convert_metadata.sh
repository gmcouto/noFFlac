#!/usr/bin/env bash

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
# - The EXTRA field contains JSON data that will be parsed and added as individual metadata entries

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

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
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
    "FILE_MODIFIED_DATE"
    "FILE_MODIFIED_DATE_LOCAL"
    "CHANNELS"
    "SAMPLINGRATE"
    "BITDEPTH"
    "MD5_UNDECODED"
)

# Global variables to track processed state
declare -g processed_title=0

# Define metadata mapping (M4A to FLAC)
# Using a simpler approach without associative arrays
map_key() {
    declare -g processed_title
    # Convert input to uppercase for case-insensitive comparison
    local upper_key=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    case "$upper_key" in
        "TITLE"|"TRACK")
            echo "Title"
            ;;
        "ALBUM") echo "Album" ;;
        "ALBUM_PERFORMER") echo "AlbumArtist" ;;
        "PART_POSITION") echo "DiscNumber" ;;
        "PART_POSITION_TOTAL") echo "TotalDiscs" ;;
        "TRACK_POSITION") echo "TrackNumber" ;;
        "TRACK_POSITION_TOTAL") echo "TotalTracks" ;;
        "PERFORMER") echo "Artist" ;;
        "COMPOSER") echo "Composer" ;;
        "PRODUCER") echo "Producer" ;;
        "RECORDED_DATE") echo "Date" ;;
        "ISRC") echo "ISRC" ;;
        "COPYRIGHT") echo "Copyright" ;;
        "LYRICS") echo "Lyrics" ;;
        "RATING") echo "Rating" ;;
        *) echo "$1" ;;
    esac
}

# Function to process JSON from EXTRA field
process_extra_json() {
    local json_data="$1"
    local output_file="$2"
    
    # Use jq to extract key-value pairs, replace underscores with spaces in keys, and format them
    echo "$json_data" | jq -r 'to_entries | .[] | "\(.key | gsub("_"; " "))=\(.value)"' >> "$output_file"
}

# Create or clear the output file
> "$outputFile"

# Flag to track if EXTRA has been processed
extra_processed=0

# Process the input file
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Skip lines starting with @
    [[ "$line" =~ ^@ ]] && continue
    
    # Split the line into key and value
    key="${line%%=*}"
    value="${line#*=}"
    
    # Skip blacklisted keys (case insensitive)
    skip=0
    upper_key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
    for blacklisted in "${BLACKLISTED_METADATA_KEYS[@]}"; do
        if [[ "$upper_key" == "$blacklisted" ]]; then
            skip=1
            break
        fi
    done
    [[ $skip -eq 1 ]] && continue
    
    # Special handling for EXTRA field - only process first occurrence
    if [[ $(echo "$key" | tr '[:lower:]' '[:upper:]') == "EXTRA" ]]; then
        if [[ $extra_processed -eq 0 ]]; then
            process_extra_json "$value" "$outputFile"
            extra_processed=1
        fi
        continue
    fi
    
    # Map the key and write to output
    mapped_key=$(map_key "$key")
    # Skip duplicate Title if already processed
    if [[ "$mapped_key" == "Title" ]]; then
        if [[ $processed_title -eq 1 ]]; then
            continue
        else
            processed_title=1
        fi
    fi
    echo "${mapped_key}=${value}"
    echo "${mapped_key}=${value}" >> "$outputFile"
done < "$inputFile"

echo "Metadata conversion completed. Output written to '$outputFile'"