#!/bin/sh

# Keyboard layout (optional)
setxkbmap -layout "us,gr" -variant ",polytonic" -option "grp:shifts_toggle,compose:ralt, ctrl:swapcaps" &

# Run single-monitor mode
"$HOME/bin/2mon.sh" &

# Run the script in the background
~/bin/statusbar.sh &

# wacom setup
~/wacom-setup.sh &

# Cursor settings
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=16

# Start Redshift (Reads config from ~/.config/redshift/redshift.conf)
redshift &

# Notification Daemon
dunst &

# Automount USBs (tray icon enabled if you have systray patch)
udiskie &

# Polkit Authentication Agent (Password popups)
/usr/bin/lxpolkit &

# Sets the background (optional, if you have feh installed)
feh --bg-scale ~/pictures/tokyonight-wallpapers/crosses_original.png &

# Enable tap-to-click for ELAN Touchpad
xinput set-prop "ELAN0688:00 04F3:320B Touchpad" "libinput Tapping Enabled" 1 &

# 1. Set the idle timeout to 600 seconds (10 minutes)
xset s 600 600

# 2. Start xss-lock to trigger slock when the timeout hits
xss-lock -- slock &
# Start DWM
exec dwm
