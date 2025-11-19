#!/bin/sh

# Volume (PipeWire / pactl)
vol() {
    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
    MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

    if [ "$MUTED" = "yes" ]; then
        printf "🔇 %s%%" "$VOLUME"
    else
        if   [ "$VOLUME" -lt 33 ]; then ICON="🔈"
        elif [ "$VOLUME" -lt 66 ]; then ICON="🔉"
        else ICON="🔊"
        fi
        printf "%s %s%%" "$ICON" "$VOLUME"
    fi
}

# CPU load
cpu() {
    LOAD=$(awk '{print $1}' /proc/loadavg)
    printf "🖥️ %s" "$LOAD"
}

# Clock
clock() {
    printf "📅 %s" "$(date '+%a %d %b  %H:%M')"
}

# Combine
status() {
    printf "%s | %s | %s" "$(vol)" "$(cpu)" "$(clock)"
}

# Set DWM bar
xsetroot -name "$(status)"

