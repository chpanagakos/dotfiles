#!/bin/sh

# Define your Web Apps
# format: [Icon] [Name] | [URL]
SITES="🤖 Gemini      | https://gemini.google.com
💬 ChatGPT     | https://chat.openai.com
📺 YouTube     | https://www.youtube.com
🐙 GitHub      | https://github.com
📧 Gmail       | https://mail.google.com
🎵 Spotify     | https://open.spotify.com
🌥️ Weather     | https://wttr.in/papadianika
🛍️ Skroutz     | https://www.skroutz.gr"

# Pipe to dmenu
SELECTED=$(echo "$SITES" | dmenu -i -p "Web App:" -l 10)

# Exit if no selection
[ -z "$SELECTED" ] && exit 0

# Extract URL
URL=$(echo "$SELECTED" | cut -d'|' -f2 | xargs)

# Browser Selection Logic
if command -v chromium >/dev/null 2>&1; then
    BROWSER="chromium"
elif command -v google-chrome-stable >/dev/null 2>&1; then
    BROWSER="google-chrome-stable"
elif command -v brave-browser >/dev/null 2>&1; then
    BROWSER="brave-browser"
else
    firefox --new-window "$URL"
    exit 0
fi

# Launch in App Mode
setsid "$BROWSER" --app="$URL" >/dev/null 2>&1 &
