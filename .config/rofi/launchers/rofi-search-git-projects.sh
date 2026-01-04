#!/usr/bin/env bash

# 🔧 Các thư mục chứa project Git
PROJECT_DIRS=(
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Desktop"
    "$HOME/Projects"
)

# 🔥 Loại trừ các thư mục không mong muốn
EXCLUDED_DIRS=(
    node_modules .cache .cargo .rustup venv __pycache__ .mypy_cache dist build out
    target .idea .vscode .next .vite .local/share/Trash .var .flatpak .steam .thumbnails
    .snap .wine .android .gradle __pypackages__ .venv .pytest_cache .ipynb_checkpoints
    .DS_Store .history coverage .scannerwork .settings
)

# Chuyển danh sách thành đối số cho fd
EXCLUDE_ARGS=()
for dir in "${EXCLUDED_DIRS[@]}"; do
    EXCLUDE_ARGS+=(--exclude "$dir")
done

# Tìm repo Git
REPO_PATHS=()
for dir in "${PROJECT_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    mapfile -t found < <(
        fd --hidden --type d -I -d 16 '.git' "$dir" \
            "${EXCLUDE_ARGS[@]}" 2>/dev/null |
            sed 's|/.git||'
    )
    REPO_PATHS+=("${found[@]}")
done

# Không tìm thấy
if [ ${#REPO_PATHS[@]} -eq 0 ]; then
    notify-send "No Git repositories found."
    exit 0
fi

# 📦 Xử lý tên hiển thị
declare -A NAME_COUNT
declare -A PATH_MAP
for path in "${REPO_PATHS[@]}"; do
    name=$(basename "$path")
    ((NAME_COUNT["$name"]++))
    PATH_MAP["$path"]="$name"
done

DISPLAY_LIST=()
declare -A DISPLAY_TO_PATH
for path in "${REPO_PATHS[@]}"; do
    name="${PATH_MAP["$path"]}"
    if ((NAME_COUNT["$name"] > 1)); then
        display="$path"
    else
        display="$name"
    fi
    DISPLAY_LIST+=("$display")
    DISPLAY_TO_PATH["$display"]="$path"
done

# 🧭 Hiển thị với rofi
SELECTED=$(printf "%s\n" "${DISPLAY_LIST[@]}" | rofi -dmenu -i -p "📂 Git Projects")

# 🚀 Mở terminal nếu có chọn
if [ -n "$SELECTED" ]; then
    kitty --working-directory "${DISPLAY_TO_PATH["$SELECTED"]}"
    # hoặc mở bằng code:
    # code "${DISPLAY_TO_PATH["$SELECTED"]}"
fi
