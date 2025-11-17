#!/bin/sh

# Keyboard layout (optional)
setxkbmap -layout "us,gr" -option "grp:alt_shift_toggle"

# Run single-monitor mode
"$HOME/bin/2mon.sh" &

# Run compositor if you ever want (not needed with NVIDIA)
# picom --experimental-backends &

# Start DWM
exec dwm
