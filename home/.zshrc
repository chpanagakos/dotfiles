# =============================================================================
# ~/.zshrc
# =============================================================================

# -----------------------------------------------------------------------------
# Completions
# -----------------------------------------------------------------------------
fpath=(~/.zsh/zsh-completions/src $fpath)
autoload -Uz compinit && compinit

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # share history across sessions
setopt HIST_IGNORE_DUPS       # no duplicate entries
setopt HIST_IGNORE_SPACE      # don't save lines starting with space
setopt HIST_VERIFY            # show substituted history before executing

# -----------------------------------------------------------------------------
# Navigation
# -----------------------------------------------------------------------------
setopt AUTO_CD                # type a dir name to cd into it
setopt AUTO_PUSHD             # cd pushes to directory stack
setopt PUSHD_IGNORE_DUPS      # no duplicate dirs in stack

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestion style — subtle, not distracting
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'   # Tokyo Night comment colour
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# -----------------------------------------------------------------------------
# Keybindings
# -----------------------------------------------------------------------------
bindkey -e                                      # emacs-style line editing
bindkey '^[[A' history-search-backward          # up arrow — history search
bindkey '^[[B' history-search-forward           # down arrow
bindkey '^[^[[C' forward-word                   # alt+right — skip word
bindkey '^[^[[D' backward-word                  # alt+left
bindkey '^[[1;5C' forward-word                  # ctrl+right (some terminals)
bindkey '^[[1;5D' backward-word                 # ctrl+left
bindkey '^[[H' beginning-of-line                # Home
bindkey '^[[F' end-of-line                      # End
# Accept autosuggestion with right arrow or End
bindkey '^[[C' autosuggest-accept
bindkey '^[[F' autosuggest-accept

# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# Tokyo Night colours
# %F{colour} ... %f  sets foreground
# %B ... %b          bold
# %(?. . )           conditional on exit code

# Git info via vcs_info
zstyle ':vcs_info:git:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{#7aa2f7}(%b%u%c%F{#7aa2f7})%f' #branch
zstyle ':vcs_info:git:*' actionformats ' %F{#f7768e}(%b|%a%u%c%F{#f7768e})%f' # branch|action (rebase etc)
zstyle ':vcs_info:git:*' unstagedstr '%F{#e0af68}*%f'               # dirty — unstaged
zstyle ':vcs_info:git:*' stagedstr '%F{#9ece6a}+%f'                 # staged
zstyle ':vcs_info:git:*' check-for-changes true

# Python venv
_venv_info() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo " %F{#bb9af7}($(basename $VIRTUAL_ENV))%f"
    fi
}

# Build prompt before each command
_build_prompt() {
    vcs_info
}
add-zsh-hook precmd _build_prompt

setopt PROMPT_SUBST

# Prompt layout:
# [exitcode] ~/path/here (branch*) (venv) ❯
PROMPT='%(?.%F{#9ece6a}.%F{#f7768e})❯%f '   # ❯ green if ok, red if error

RPROMPT='%F{#7dcfff}%~%f${vcs_info_msg_0_}$(_venv_info)'
# Right prompt: path in blue, git branch, venv

# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# pyenv (uncomment if managing multiple Python versions)
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R --use-color'

# -----------------------------------------------------------------------------
# Yazi — cd on quit
# -----------------------------------------------------------------------------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# -----------------------------------------------------------------------------
# Abbreviations (zsh-abbr — expands in place like Fish)
# -----------------------------------------------------------------------------
source ~/.zsh/zsh-abbrev-alias/abbrev-alias.plugin.zsh
abbrev-alias ll='ls -l'
abbrev-alias la='ls -la'
abbrev-alias gs='git status'
abbrev-alias ga='git add'
abbrev-alias gc='git commit -m'
abbrev-alias gp='git push'
abbrev-alias gl='git log --oneline --graph --decorate'
abbrev-alias gd='git diff'
# abbrev-alias y='yazi'
abbrev-alias vim='nvim'
abbrev-alias v='nvim'
abbrev-alias fd='fdfind'
abbrev-alias texbuild='latexmk -xelatex'
abbrev-alias telegram='~/.local/lib/telegram/Telegram'
abbrev-alias upd='sudo apt update'
abbrev-alias upg='sudo apt upgrade'
abbrev-alias inst='sudo apt install'
abbrev-alias dotfiles='cd ~/dotfiles'

# -----------------------------------------------------------------------------
# Core aliases (non-abbreviations — these don't need to be visible before run)
# -----------------------------------------------------------------------------
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias cp='cp -iv'
alias mv='mv -iv'
# alias rm='rm -iv'
alias mkdir='mkdir -pv'

# -----------------------------------------------------------------------------
# Auxiliary aliases 
# -----------------------------------------------------------------------------
alias airpods='bluetoothctl connect F8:D3:F0:6B:F3:BD'
alias airoff='bluetoothctl disconnect F8:D3:F0:6B:F3:BD'

# -----------------------------------------------------------------------------
# SSH agent — start once, load key, stays unlocked for the session
# -----------------------------------------------------------------------------
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# -----------------------------------------------------------------------------
# Yazi: y opens Yazi and drops you in whatever directory you navigated to when you quit.
# -----------------------------------------------------------------------------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm "$tmp"
}
