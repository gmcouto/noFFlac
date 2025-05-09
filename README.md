# noFFlac - M4A to FLAC converter WITHOUT ffmpeg

A command-line tool that converts M4A audio files to FLAC format while preserving metadata and cover art. This tool was created specifically for those who want to avoid using FFmpeg for various reasons (like having friends who passionately dislike it 😅).

## Why This Exists

While FFmpeg is a powerful and widely-used tool for media conversion, some people prefer alternatives for various reasons:
- Simpler, more focused functionality
- No need to deal with FFmpeg's extensive (and sometimes overwhelming) options
- Avoiding potential licensing concerns
- Personal preferences (like having friends who get triggered by FFmpeg 😉)

This tool provides a lightweight, FFmpeg-free solution that focuses solely on converting M4A files to FLAC while maintaining all the important metadata and cover art.

## Features

- Converts M4A files to FLAC format
- Preserves all metadata (artist, album, title, etc.)
- Extracts and embeds cover art
- Maintains audio quality
- No FFmpeg dependency required
- Debug mode for troubleshooting

## Prerequisites

### macOS
- Homebrew (for package management)
- bento4 (for M4A processing)
- flac (for FLAC conversion)
- mediainfo (for metadata handling)
- jq (for JSON processing)

### Linux
- bento4 (for M4A processing)
- flac (for FLAC conversion)
- metaflac (for FLAC metadata)
- mediainfo (for metadata handling)
- jq (for JSON processing)

## Installation

### macOS
```bash
./setup_macos.sh
```

### Linux
```bash
./setup_linux.sh
```

## Usage

Basic usage:
```bash
./convert.sh input.m4a
```

Debug mode (keeps temporary files):
```bash
./convert.sh -debug input.m4a
```

The converted file will be saved in the `output` directory with the same name but with a `.flac` extension.

## Project Structure

```
.
├── convert.sh              # Main conversion script
├── setup_macos.sh         # macOS setup script
├── setup_linux.sh         # Linux setup script
├── src/
│   ├── extract_m4a_metadata.sh
│   ├── extract_m4a_cover.sh
│   ├── extract_m4a_raw_audio_track.sh
│   └── build_flac_from_metadata.sh
├── output/                # Output directory for converted files
└── temp/                  # Temporary files (cleaned up after conversion)
```

## How It Works

1. Extracts metadata from the M4A file
2. Extracts the raw audio track
3. Extracts the cover art
4. Builds a new FLAC file with all the extracted data

## Debug Mode

When using the `-debug` flag, temporary files are kept in the `temp` directory. This is useful for:
- Troubleshooting conversion issues
- Inspecting intermediate files
- Understanding the conversion process

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 