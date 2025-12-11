#!/bin/bash

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$STATE_DIR/wacom-map-state"
mkdir -p "$STATE_DIR"

# 1. Get stylus ID
STYLUS=$(xsetwacom --list devices \
  | grep "Wacom One by Wacom" \
  | grep "stylus" \
  | awk -F "id: " '{print $2}' \
  | awk '{print $1}')

# 2. HDMI-0 geometry (e.g. 1920x1080+640+1440)
HDMI_GEOM=$(xrandr | awk '/^HDMI-0 connected/ {print $3}')

# 3. Primary monitor geometry (field 4 on the 'primary' line)
PRIMARY_GEOM=$(xrandr | awk '$3 == "primary" {print $4; exit}')

# Optional: fallback if, for some reason, no primary is set
if [ -z "$PRIMARY_GEOM" ]; then
  PRIMARY_GEOM=$(xrandr | awk '/ connected/ && $2=="connected" {print $3; exit}')
fi

# 4. Read last state (default = MAIN)
if [ -f "$STATE_FILE" ]; then
    LAST=$(cat "$STATE_FILE")
else
    LAST="MAIN"
fi

# 5. Toggle logic
if [ "$LAST" = "MAIN" ] && [ -n "$HDMI_GEOM" ]; then
    TARGET="$HDMI_GEOM"
    echo "HDMI" > "$STATE_FILE"
else
    TARGET="$PRIMARY_GEOM"
    echo "MAIN" > "$STATE_FILE"
fi

# 6. Apply mapping
xsetwacom set "$STYLUS" MapToOutput "$TARGET"

# 7. Buttons
xsetwacom set "$STYLUS" Button 2 2
xsetwacom set "$STYLUS" Button 3 3

# 8. Output message
echo "Mapped Wacom stylus (id $STYLUS) to region: $TARGET"

