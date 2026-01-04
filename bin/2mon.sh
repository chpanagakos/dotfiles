#!/bin/sh

xrandr \
  --output DP-4 --mode 2560x1440 --rate 59.95 --primary --pos 0x0 \
  --output HDMI-0 --mode 1920x1080 --rate 60 --pos 640x1440 \
  --output DP-2 --off

