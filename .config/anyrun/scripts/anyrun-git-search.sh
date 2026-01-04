#!/usr/bin/env bash

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

PROJECT_DIRS=(
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Desktop"
    "$HOME/Projects"
)

EXCLUDED_DIRS=(
    node_modules .cache .cargo .rustup venv __pycache__ .mypy_cache dist build out
    target .idea .vscode .next .vite .local/share/Trash .var .flatpak .steam .thumbnails
    .snap .wine .android .gradle __pypackages__ .venv .pytest_cache .ipynb_checkpoints
    .DS_Store .history coverage .scannerwork .settings
)

EXCLUDE_ARGS=()
for dir in "${EXCLUDED_DIRS[@]}"; do
    EXCLUDE_ARGS+=(--exclude "$dir")
done

mapfile -t REPO_PATHS < <(
    for dir in "${PROJECT_DIRS[@]}"; do
        [[ -d "$dir" ]] || continue
        fd --hidden --type d -I -d 16 '.git' "$dir" "${EXCLUDE_ARGS[@]}" 2>/dev/null | sed 's|/.git||'
    done
)

if [ ${#REPO_PATHS[@]} -eq 0 ]; then
    [[ -n "$1" ]] && notify-send "Anyrun" "No Git repositories found."
    exit 0
fi

if [ -z "$1" ]; then
    declare -A NAME_COUNT
    for path in "${REPO_PATHS[@]}"; do
        name=$(basename "$path")
        ((NAME_COUNT["$name"]++))
    done

    for path in "${REPO_PATHS[@]}"; do
        name=$(basename "$path")
        if ((NAME_COUNT["$name"] > 1)); then
            echo "$path | $path"
        else
            echo "$name | $path"
        fi
    done
    exit 0
fi

RAW_INPUT="$1"
TARGET_PATH="${RAW_INPUT##* | }"

if [[ -d "$TARGET_PATH" ]]; then
    kitty --working-directory "$TARGET_PATH" &

else
    notify-send "Error" "Directory no longer exists: $TARGET_PATH"
    exit 1
fi
