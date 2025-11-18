#!/bin/bash

# Usage: run-ocr filename.pdf
INPUT="$1"

# Create the output name: "file.pdf" -> "file_ocr.pdf"
# ${INPUT%.*} removes the extension
OUTPUT="${INPUT%.*}_ocr.pdf"

echo "OCR-ing: $INPUT -> $OUTPUT"

# Run the command
# --force-ocr: Ignores "Tagged PDF" errors from Simple Scan
# --deskew: Straightens pages
ocrmypdf --force-ocr --deskew -l eng+ell "$INPUT" "$OUTPUT"
