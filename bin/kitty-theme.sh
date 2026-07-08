#!/bin/sh
f="$HOME/.config/kitty/current-theme.conf"
if grep -q "Tokyo Night Day" "$f" 2>/dev/null; then
    kitten themes --reload-in=all "Tokyo Night"
else
    kitten themes --reload-in=all "Tokyo Night Day"
fi
