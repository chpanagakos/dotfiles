#!/usr/bin/env bash

read -p "Image name (without extension): " name

if [ -z "$name" ]; then
    echo "No name provided."
    exit 1
fi

outfile="$(pwd)/${name}.png"

# Try PNG
if xclip -selection clipboard -t image/png -o > "$outfile" 2>/dev/null; then
    echo "Saved: $outfile"
    exit 0
fi

# Fallback BMP
if xclip -selection clipboard -t image/bmp -o > "$outfile" 2>/dev/null; then
    echo "Saved: $outfile"
    exit 0
fi

echo "No image found in clipboard."
exit 1

