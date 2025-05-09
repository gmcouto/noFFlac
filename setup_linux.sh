#!/usr/bin/env bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update package list
apt-get update

# Install required packages
apt-get install -y \
    bento4 \
    flac \
    metaflac \
    mediainfo \
    jq

echo "Setup completed successfully" 