#!/usr/bin/env bash
# run-ocr: Convert a scanned PDF into a searchable, deskewed PDF.
# Usage: run-ocr input.pdf
# Produces: input_ocr.pdf
# Uses ocrmypdf with --force-ocr and --deskew for reliable text extraction.

set -euo pipefail
IFS=$'\n\t'

# Simple wrapper around ocrmypdf
# Usage: run-ocr file.pdf  -> produces file_ocr.pdf

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") file.pdf"
  exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: file '$INPUT' not found."
  exit 1
fi

if ! command -v ocrmypdf >/dev/null 2>&1; then
  echo "Error: 'ocrmypdf' is not installed."
  exit 1
fi

OUTPUT="${INPUT%.*}_ocr.pdf"

echo "OCR-ing: $INPUT -> $OUTPUT"

# --force-ocr: Ignores 'Tagged PDF' errors from Simple Scan
# --deskew: Straightens pages
ocrmypdf --force-ocr --deskew -l eng+ell "$INPUT" "$OUTPUT"

echo "Done."

