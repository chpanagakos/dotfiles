#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Go to the directory where this script lives (the repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color codes for fancy output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[+] $1${NC}"; }
err() { echo -e "${RED}[!] $1${NC}"; }

# Ensure directories exist
mkdir -p ~/.config
mkdir -p ~/wm
mkdir -p ~/bin

if ! command -v stow >/dev/null 2>&1; then
    err "Error: 'stow' is not installed. Run: sudo apt install stow"
    exit 1
fi

# --- Function: Backup if file exists and is NOT a symlink ---
backup_if_exists() {
    local file="$1"
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        log "Backing up existing $file to $file.bak"
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
}

log "Checking for conflicts..."
# Check specific files that Debian creates by default
backup_if_exists ".bashrc"
backup_if_exists ".profile"
backup_if_exists ".bash_logout"

log "Stowing Dotfiles..."

# Use -R (Restow) to prune old links and create new ones
# 1. Home (Files that go to ~)
stow -R -v -t ~ home

# 2. Config (Files that go to ~/.config)
stow -R -v -t ~/.config config

# 3. Window Manager (Files that go to ~/wm)
stow -R -v -t ~/wm wm

# 4. Binaries (Files that go to ~/bin)
stow -R -v -t ~/bin bin

log "Done! Your workspace is ready."
