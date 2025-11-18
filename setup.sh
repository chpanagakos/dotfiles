#!/bin/bash

# Ensure directories exist
mkdir -p ~/.config
mkdir -p ~/wm
mkdir -p ~/bin  # <--- MUST be created before stowing

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
