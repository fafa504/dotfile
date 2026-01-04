#!/usr/bin/env bash

# ALIAS RELOAD CONFIG
alias reload="source $HOME/.zshrc"

# NAVIGATION & SHELL BASICS
alias ..="cd .."
alias ".2"="cd .."
alias ...="cd ../.."
alias ".3"="cd ../.."
alias ".4"="cd ../../.."
alias de="cd $HOME/Desktop"
alias c="clear"
alias cls="clear"
alias /e="exit"

# Git
alias gcw="git clone $(wl-paste)"

# Modern LS replacement (eza)
alias ls='eza --color=always --icons --group-directories-first --header --time-style=long-iso'

# GUI File Manager
alias dolphin="xdg-open . && exit"

# Clipboard
alias copy="wl-copy"
alias pwdc="pwd | wl-copy"
alias paste="wl-paste"

# SYSTEM & PACKAGE MANAGEMENT (Arch Linux)
alias update-db="update-desktop-database $HOME/.local/share/applications/"

# System Control
alias st='systemctl-tui'
alias lock='loginctl lock-session'
alias x11="env GDK_BACKEND=x11"
alias cleantrash='echo -n "Taking out the trash..." | pv -qL 10 && rm -rf $HOME/.local/share/Trash/files && fastfetch'

# EDITORS & DOTFILES
alias vim='nvim'
alias cfnv="cd $HOME/.config/nvim && nvim"
alias cfz="cd $HOME/.config/shell && nvim $HOME/.zshrc && source $HOME/.zshrc"

# IDEs (Launch and close terminal)
alias code='code . && exit'
alias zed='zeditor . && exit'

# Syncthing
alias syncthing-config="nvim $HOME/.local/state/syncthing/config.xml"
alias syncthing-web="xdg-open http://localhost:8384/#"

# DEVELOPMENT & GIT
alias cm="cargo watch -x build -x test -x run"
alias piorun='pio run -t upload -t monitor'
alias tauri-build="NO_STRP=true pnpm tauri build"

# AI TOOLS
# alias fabric="fabric-ai -m 'gemini-2.5-flash-lite-preview-06-17'"

# Aider Models (Configured via OpenRouter)
# alias aider_gemini_pro="aider --model gemini-2.5-pro-exp-03-25"
# alias aider_gemini_flash="aider --model openrouter/google/gemini-2.0-flash-exp:free"
# alias aider_deepseek="aider --model openrouter/deepseek/deepseek-r1:free"
# alias aider_llama="aider --model openrouter/meta-llama/llama-4-maverick:free"

# TMUX
alias t='tmux attach -t main || tmux new -s main' # Auto attach or create 'main'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'
alias td='tmux detach'
alias tls='tmux ls'
alias tl='tmux list-sessions'

# UTILITIES & SEARCH
alias ff="fastfetch"
alias of="onefetch --disabled-fields description head pending version dependencies authors last-change url churn license --no-art --no-title --no-color-palette"
alias vii="trans -t vi -I"

# Kill process with FZF
alias fkill='ps -ef | fzf | awk "{print \$2}" | xargs kill'

# History Search with FZF (Copies command to clipboard)
alias hf='HISTTIMEFORMAT= history | sed -E "s/^[[:space:]]*[0-9]+\*?[[:space:]]*//" | fzf --no-preview --height=40% --layout=default | wl-copy && echo "Copied to clipboard: $(wl-paste)"'
alias hfe='HISTTIMEFORMAT= history | fzf --no-preview --height=40% --reverse --tac | sed -E "s/^[[:space:]]*[0-9]+\*?[[:space:]]*//" | bash'

## Taskwarror-tui
alias tt="taskwarrior-tui"

## Project
alias prj="cd ~/Projects"

## Clipboard
alias gcl="qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardContents"
