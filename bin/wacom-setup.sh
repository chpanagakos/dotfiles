#!/bin/bash

# 1. Get IDs
# Note: Grepping "Wacom One by Wacom" specifically for the CTL-672
STYLUS=$(xsetwacom --list devices | grep "stylus" | grep "Wacom One by Wacom" | awk -F "id: " '{print $2}' | awk '{print $1}')

# 2. Map Screen (As discussed previously)
if xrandr | grep -q "HDMI-0 connected"; then
    xsetwacom set "$STYLUS" MapToOutput 1920x1080+640+1440
else
    xsetwacom set "$STYLUS" MapToOutput DP-4
fi

# 3. Configure Buttons for "Hold to Erase"
# Button 2 = The button closer to the pen tip.
# We map it to Middle Click (2).
xsetwacom set "$STYLUS" Button 2 2

# Button 3 = The button further up the barrel.
# We map it to Right Click (3) for context menus.
xsetwacom set "$STYLUS" Button 3 3
