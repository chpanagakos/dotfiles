#!/bin/sh

xrandr \
  --output DP-4 --mode 2560x1440 --rate 59.95 --primary --pos 1920x0 \
  --output HDMI-0 --mode 1920x1080 --rate 60 --pos 0x1080 \
  --output DP-2 --mode 1920x1080 --rate 60 --pos 0x0

