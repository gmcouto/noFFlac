#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install it first from https://brew.sh"
    exit 1
fi

# Update Homebrew
brew update

# Install required packages
brew install \
    bento4 \
    flac \
    mediainfo \
    jq

echo "Setup completed successfully"