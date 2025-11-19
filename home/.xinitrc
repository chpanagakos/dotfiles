#!/bin/sh

# Keyboard layout (optional)
setxkbmap -layout "us,gr" -variant ",polytonic" -option "grp:shifts_toggle,compose:ralt" &

# Run single-monitor mode
"$HOME/bin/2mon.sh" &

# Run compositor if you ever want (not needed with NVIDIA)
# picom --experimental-backends &

# Statusbar refresh
# while true; do
#     "$HOME/bin/statusbar.sh"
#     sleep 1
# done &

# Kill any existing statusbar scripts to prevent duplicates if you reload
pkill -f "statusbar.sh"

# Run the script in the background
~/bin/statusbar.sh &


# Cursor settings
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=16

# Start Redshift (Reads config from ~/.config/redshift/redshift.conf)
redshift -c ~/.config/redshift/redshift.conf &

# Notification Daemon
dunst &

# Automount USBs (tray icon enabled if you have systray patch)
udiskie &

# Polkit Authentication Agent (Password popups)
/usr/bin/lxpolkit &

# Sets the background (optional, if you have feh installed)
# feh --bg-scale ~/path/to/wallpaper.jpg &

# Start DWM
exec dwm
