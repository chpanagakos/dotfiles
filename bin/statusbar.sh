#!/bin/sh

# Interval in seconds
INTERVAL=1

# Battery Logic (Direct Sysfs reading)
batt() {
    # Adjust "BAT0" if your system uses "BAT1"
    PATH_BATT="/sys/class/power_supply/BAT0"
    
    # Check if battery exists (for desktop safety)
    if [ ! -d "$PATH_BATT" ]; then
        return
    fi

    CAPACITY=$(cat "$PATH_BATT/capacity")
    STATUS=$(cat "$PATH_BATT/status")

    # Determine Icon based on state and level
    if [ "$STATUS" = "Charging" ]; then
        ICON="󱐋" # Charging bolt
    elif [ "$STATUS" = "Full" ]; then
        ICON="󰁹" # Full icon
    else
        # Discharging logic
        if   [ "$CAPACITY" -lt 20 ]; then ICON="󰁻" # Low
        elif [ "$CAPACITY" -lt 50 ]; then ICON="󰁾" # Mid
        elif [ "$CAPACITY" -lt 80 ]; then ICON="󰂀" # High
        else ICON="󰁹"
        fi
    fi

    printf "%s %s%%" "$ICON" "$CAPACITY"
}

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

# Add this function to your ~/bin/statusbar.sh
brightness() {
    # Get current brightness percentage
    BRIGHT=$(brightnessctl i | grep -oP '\(\K\d+(?=%\))')
    
    # Icon logic using Caskaydia Cove
    if   [ "$BRIGHT" -lt 30 ]; then ICON="󰃞" # Dim
    elif [ "$BRIGHT" -lt 71 ]; then ICON="󰃟" # Medium
    else ICON="󰃠" # High
    fi

    printf "%s %s%%" "$ICON" "$BRIGHT"
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
    STATUS="$(batt) | $(vol)  | $(brightness) | $(cpu)  |  $(clock)"
    
    # Set root name
    xsetroot -name "$STATUS"
    
    # Wait before next update
    sleep $INTERVAL
done
