#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# SYSTEM & LOCALE
# ------------------------------------------------------------------------------
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export GTK_USE_PORTAL=1
export ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# ------------------------------------------------------------------------------
# DEFAULT APPLICATIONS
# ------------------------------------------------------------------------------
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"

# Clipboard: Detect Wayland (wl-copy) vs X11 (xclip)
if command -v wl-copy >/dev/null 2>&1; then
    export CLIPCOPY="wl-copy"
    export CLIPPASTE="wl-paste"
else
    export CLIPCOPY="xclip -selection clipboard -in"
    export CLIPPASTE="xclip -selection clipboard -out"
fi

# ------------------------------------------------------------------------------
# SDKs & LANGUAGES
# ------------------------------------------------------------------------------
# Java & Android
export JAVA_HOME="/usr/lib/jvm/java-25-openjdk"
export ANDROID_HOME="$HOME/Android/Sdk"
export _JAVA_AWT_WM_NONREPARENTING=1

# Node / JS
export PNPM_HOME="$HOME/.local/share/pnpm"

# AI / ML
export OLLAMA_HOST="127.0.0.1"

# Shell
export ZSH="$HOME/.oh-my-zsh"

# ------------------------------------------------------------------------------
# PATH MANAGEMENT
# Order: Custom Bin > Language Bin > System Bin
# ------------------------------------------------------------------------------

# Helpers: Only add to PATH if directory exists
path_prepend() { [[ -d "$1" ]] && export PATH="$1:$PATH"; }
path_append() { [[ -d "$1" ]] && export PATH="$PATH:$1"; }

# 1. High Priority (User Scripts)
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.config/shell/bin"

# 2. Language & SDK Binaries
path_prepend "$HOME/.luarocks/bin"
path_prepend "$HOME/.spicetify"
path_prepend "$HOME/.config/composer/vendor/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.npm/bin"
path_prepend "$HOME/.pnpm/bin"
path_prepend "$GOBIN"
path_prepend "$HOME/flutter/bin"
path_prepend "$HOME/development/flutter/bin"
path_prepend "$JAVA_HOME/bin"
path_prepend "$PNPM_HOME"

# 3. System / App Specific
path_append "/usr/lib64/qt5/bin"

# Cleanup helpers
unset -f path_prepend path_append

# ------------------------------------------------------------------------------
# TOOL CONFIGURATION
# ------------------------------------------------------------------------------

# --- FZF (Fuzzy Finder) ---
EXCLUDED_DIRS=(
    .git node_modules .cache .cargo .rustup venv __pycache__ .mypy_cache
    dist build out target .idea .vscode .next .vite .local/share/Trash
    .var .flatpak .steam .thumbnails .snap .wine .android .gradle
    __pypackages__ .venv .pytest_cache .ipynb_checkpoints go/pkg
    .DS_Store coverage .scannerwork .settings
)

__utils_fd_run() {
    local base_dir="."
    # shift

    local exclude_args=()
    for dir in "${EXCLUDED_DIRS[@]}"; do
        exclude_args+=(-E "$dir")
    done

    fd "${extra_args[@]}" "${exclude_args[@]}" . "$base_dir" -t f 2>/dev/null
}

for dir in "${EXCLUDED_DIRS[@]}"; do
    exclude_args+=(-E "$dir")
done

# Format exclusions for FZF command
export FZF_DEFAULT_COMMAND="fd "${exclude_args[@]}" . -t f --hidden"
export FZF_COMPLETION_TRIGGER=','
export FZF_TMUX_OPTS='-p 90%'
export FZF_CTRL_T_COMMAND="fd "${exclude_args[@]}" . -t f --hidden"
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

export FZF_DEFAULT_OPTS="\
    --layout=reverse --info=inline --height=80% --multi --cycle \
    -m --reverse \
    --margin=1 --border=rounded \
    --prompt=' ' --pointer=' ' --marker=' ' \
    --color='hl:148,hl+:154,prompt:blue,pointer:032,marker:010,bg+:000,gutter:000' \
    --preview-window=right:65% \
    --bind '?:toggle-preview' \
    --bind 'esc:execute-silent(kitty icat --clear)+abort'
    --bind 'ctrl-c:execute-silent(kitty icat --clear)+abort'
    --bind 'ctrl-a:select-all' \
    --bind 'tab:toggle-out' \
    --bind 'shift-tab:toggle-in' \
    --bind 'ctrl-y:execute-silent(echo {+} | $CLIPCOPY)' \
    --bind 'ctrl-e:execute($TERMINAL $EDITOR {+})+reload(fzf)' \
    --preview '$HOME/.config/shell/lib/helper/preview.sh {}'"

# --- Bat (better cat) ---
export BAT_THEME="Catppuccin Frappe"

# --- Rclone (Cloud Sync) ---
export RCLONE_LOG_FILE="$HOME/rclone-sync.log"

rclone_params=(
    "--progress"              # Show progress bar
    "--fast-list"             # Reduce API calls (recursive list)
    "--checkers=16"           # Parallel file checkers
    "--transfers=8"           # Parallel file transfers
    "--tpslimit=10"           # Limit transactions per second (Google limit)
    "--tpslimit-burst=10"     # Burst limit
    "--drive-chunk-size=128M" # Large file upload chunk size
    "--buffer-size=128M"      # Memory buffer
    "--use-mmap"              # Use mmap for better I/O performance
    "--retries=10"            # Retry attempts on failure
    "--retries-sleep=10s"     # Wait time between retries
    "--log-level=INFO"        # Log verbosity
    "--log-file=$RCLONE_LOG_FILE"
)
