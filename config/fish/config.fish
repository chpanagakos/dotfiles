if status is-interactive
    # Disable the default greeting
    set -g fish_greeting

    # Initialize Starship
    starship init fish | source

    # --- Fish Abbreviations (The better alias) ---
    
    # Format: abbr --add [SHORTCUT] [COMMAND]
    
    abbr --add ll ls -l
    abbr --add la ls -la
    abbr --add gs git status
    abbr --add ga git add
    abbr --add gc git commit -m
    abbr --add vim nvim
    abbr --add texbuild latexmk -xelatex
    abbr --add telegram ~/src/Telegram/Telegram
    
    # Use 'alias' only if you really need it to NOT expand
    # alias my_alias 'echo hello'
end
