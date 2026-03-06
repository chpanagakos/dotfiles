#!/bin/sh

# Define your Web Apps
# format: [Icon] [Name] | [URL]
SITES="🤖 Gemini      | https://gemini.google.com
💬 ChatGPT     | https://chat.openai.com
🐙 GitHub      | https://github.com
📧 Gmail       | https://mail.google.com
📝 Word        | https://www.office.com/launch/word
📊 Excel       | https://www.office.com/launch/excel
📈 PowerPoint  | https://www.office.com/launch/powerpoint
📺 YouTube     | https://www.youtube.com
🎥 Criterion   | https://www.criterionchannel.com/browse
📡 Cosmote     | https://www.cosmotetvott.gr/#!/home
🎵 Spotify     | https://open.spotify.com
🛍️ Skroutz     | https://www.skroutz.gr
🌥️ Weather     | https://wttr.in/papadianika"
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
