#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Go to the directory where this script lives (the repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure directories exist
mkdir -p ~/.config
mkdir -p ~/wm
mkdir -p ~/bin  # <--- MUST be created before stowing

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: 'stow' is not installed. Install it and re-run this script."
  exit 1
fi

echo "Stowing Dotfiles..."

# 1. Home (Files that go to ~)
stow -v -t ~ home

# 2. Config (Files that go to ~/.config)
stow -v -t ~/.config config

# 3. Window Manager (Files that go to ~/wm)
stow -v -t ~/wm wm

# 4. Binaries (Files that go to ~/bin)
stow -v -t ~/bin bin

echo "Done!"
