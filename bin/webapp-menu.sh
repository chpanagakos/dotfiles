#!/bin/sh

# Define your Web Apps as a simple multi-line string
# (No fancy arrays needed)
SITES="🤖 Gemini      | https://gemini.google.com
💬 ChatGPT     | https://chat.openai.com
📺 YouTube     | https://www.youtube.com
🐙 GitHub      | https://github.com
📧 Gmail       | https://mail.google.com
🎵 Spotify     | https://open.spotify.com
🌥️ Weather     | https://wttr.in/papadianika
   Skroutz     | https://www.skroutz.gr"

# Pipe the string directly to dmenu
# -i: Case insensitive
# -l 10: Show 10 lines
SELECTED=$(echo "$SITES" | dmenu -i -p "Web App:" -l 10)

# If user hit Esc, exit cleanly
[ -z "$SELECTED" ] && exit 0

# Extract the URL (everything after the " | ")
# We use cut because it's faster/lighter than awk for simple delimiters
URL=$(echo "$SELECTED" | cut -d'|' -f2 | xargs)

# Check for Chromium-based browser
if command -v chromium >/dev/null 2>&1; then
    BROWSER="chromium"
elif command -v google-chrome-stable >/dev/null 2>&1; then
    BROWSER="google-chrome-stable"
elif command -v brave-browser >/dev/null 2>&1; then
    BROWSER="brave-browser"
else
    # Fallback to Firefox (Standard window)
    firefox --new-window "$URL"
    exit
fi

# Launch in App Mode (detached from terminal)
setsid "$BROWSER" --app="$URL" >/dev/null 2>&1 &
