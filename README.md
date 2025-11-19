# 🌌 Systemized Debian Workspace

> **Philosophy:** Minimalist. Frictionless. Aesthetics by Tokyo Night.

This repository hosts the configuration files ("dotfiles") and source code for my personal Linux environment. It is built on **Debian**, utilizing the **Suckless** suite of tools (`dwm`, `st`, `dmenu`) to create a distraction-free, keyboard-centric workflow.

![OS](https://img.shields.io/badge/OS-Debian-red)
![Theme](https://img.shields.io/badge/Theme-Tokyo_Night-7aa2f7)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🖼️ The Aesthetic
The system follows the [Tokyo Night](https://github.com/folke/tokyo-night.nvim) color palette, balancing a dark, professional core with high-contrast readability.

* **Background:** `#1a1b26` (Storm)
* **Foreground:** `#c0caf5`
* **Accent:** `#7aa2f7` (Blue)

## 🛠️ The Stack

| Component | Choice | Notes |
| :--- | :--- | :--- |
| **OS** | Debian Stable | The bedrock. |
| **WM** | [dwm](wm/dwm) | No patches, themed, added app shortcuts |
| **Terminal** | [st](wm/st) , starship | No patches, themed |
| **Launcher** | [dmenu](wm/dmenu) | No patches, themed |
| **Shell** | Bash / Fish | Minimal prompt configuration. |
| **Editor** | Neovim | Lua config, LSP ready, LaTeX ready(vimtex) |
| **File Mgr** | Ranger | Terminal file manager with preview. |
| **PDF** | Zathura | Vim-like PDF viewer. |
| **Utilities** | Scrcpy, Dunst | Android mirroring and notification handling. |

## 📂 Repository Structure

This is a **Monorepo** setup. The source code for the window manager is included directly in the `wm/` directory. This ensures the build is frozen in time and reproducible on any machine without upstream breakage.

```text
dotfiles/
├── bin/         # Custom scripts (statusbar, monitor toggling, OCR)
├── config/      # Standard .config files (nvim, ranger, zathura, dunst, starship)
├── home/        # Home directory dotfiles (.bashrc, .xinitrc, .profile)
├── wm/          # Source code for dwm, st, dmenu
└── setup.sh     # Bootstrap script to symlink configurations
```

## 🚀 Installation

1. Dependencies

Ensure you have the necessary build tools and X11 headers installed on Debian:
Bash

sudo apt install build-essential libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libfontconfig1-dev

2. Clone & Bootstrap

Clone the repository and run the setup script to create symlinks.
Bash

git clone [https://github.com/chpanagakos/dotfiles.git](https://github.com/chpanagakos/dotfiles.git) ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh

3. Build the Suckless Tools

Compile the source code directly from the repository:
Bash

### Build dwm
cd ~/dotfiles/wm/dwm
sudo make install

### Build st
cd ~/dotfiles/wm/st
sudo make install

### Build dmenu
cd ~/dotfiles/wm/dmenu
sudo make install

## ⌨️ Keybindings (Workflow)

The Mod key is mapped to Super/Windows.
Key	Action
Mod + Return	Open Terminal (st)
Mod + p	Open Launcher (dmenu)
Mod + Shift + b	Open Browser (firefox)
Mod + Shift + Enter	Promote window to master
Mod + j / k	Focus next/prev window
Mod + h / l	Resize master area
Mod + Shift + Space	Toggle Floating mode
Mod + Shift + q	Quit dwm
Mod + Ctrl + s	Screenshot (via clipshot.sh)
F1 / F2 / F3	Switch Monitor Layouts (custom scripts)

## 🔧 Custom Scripts

Located in ~/bin/ (symlinked from dotfiles/bin/):

    statusbar.sh: Minimal loop displaying Volume, CPU load, and Clock using Nerd Fonts.
    
    [1-3]mon.sh: xrandr scripts to quickly toggle between single, dual, and triple monitor setups.
    
    run-ocr.sh: Image-to-text workflow.
    
    clipshot.sh: Screenshot utility.

## ⚠️ Note on Configuration

    Suckless Tools: Configuration is handled in config.def.h. The generated config.h is git-ignored.
    
    Secrets: SSH keys and sensitive tokens are strictly excluded via .gitignore.
