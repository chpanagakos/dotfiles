#!/bin/sh

# Interval in seconds
INTERVAL=1

# Volume (PipeWire / pactl)
vol() {
    # getting full line first reduces multiple pactl calls
    SINK_INFO=$(pactl get-sink-volume @DEFAULT_SINK@)
    MUTE_INFO=$(pactl get-sink-mute @DEFAULT_SINK@)
    
    # Extract percentage (removes % and takes the first volume found)
    VOLUME=$(echo "$SINK_INFO" | grep -oP '\d+(?=%)' | head -n 1)
    
    if echo "$MUTE_INFO" | grep -q "yes"; then
        printf "  %s%%" "$VOLUME"  # Nerd Font Mute Icon
    else
        # Minimal logic: just icon + number
        if   [ "$VOLUME" -lt 33 ]; then ICON=""
        elif [ "$VOLUME" -lt 66 ]; then ICON=""
        else ICON=""
        fi
        printf "%s  %s%%" "$ICON" "$VOLUME"
    fi
}

# CPU Load (Cleaned up)
cpu() {
    # Just the 1 minute load average for minimalism
    LOAD=$(awk '{print $1}' /proc/loadavg)
    printf "  %s" "$LOAD"
}

# Clock (Simplified format)
clock() {
    # Format: "Day DD Mon HH:MM"
    printf "  %s" "$(date '+%a %d %b %H:%M')"
}

# The Loop
while true; do
    # Calculate status
    STATUS="$(vol)  |  $(cpu)  |  $(clock)"
    
    # Set root name
    xsetroot -name "$STATUS"
    
    # Wait before next update
    sleep $INTERVAL
done
