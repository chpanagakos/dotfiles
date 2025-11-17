#!/bin/sh

xrandr \
  --output DP-4 --mode 2560x1440 --rate 165 --primary --pos 0x0 \
  --output HDMI-0 --off \
  --output DP-2 --off

