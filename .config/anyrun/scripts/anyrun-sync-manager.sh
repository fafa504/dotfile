#!/usr/bin/env bash

# --- MÔI TRƯỜNG (Wayland & XDG) ---
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

# --- CẤU HÌNH ---
# Tên hiển thị -> script thực thi
declare -A SYNC_MAP=(
    ["Obsidian"]="$HOME/.config/rofi/launchers/rofi-sync-obsidian.sh"
    ["Config"]="$HOME/.config/rofi/launchers/rofi-sync-config.sh"
    ["Firefox"]="$HOME/.config/rofi/launchers/rofi-sync-firefox.sh"
)

MAP_FILE="$XDG_RUNTIME_DIR/anyrun_sync.map"

# --- CHẾ ĐỘ 1: LIỆT KÊ (Anyrun source) ---
if [ -z "$1" ]; then
    : >"$MAP_FILE"

    for name in "${!SYNC_MAP[@]}"; do
        echo "$name"
        echo "$name|${SYNC_MAP[$name]}" >>"$MAP_FILE"
    done

    exit 0
fi

# --- CHẾ ĐỘ 2: THỰC THI (Anyrun on_select) ---
SELECTED="$1"
echo $SELECTED
EXEC_SCRIPT=${SYNC_MAP[$SELECTED]}
echo $EXEC_SCRIPT

if [[ -f "$EXEC_SCRIPT" ]]; then
    sh "$EXEC_SCRIPT" &
    notify-send "Anyrun Sync" "Đang bắt đầu: $SELECTED"
else
    notify-send "Anyrun Sync" "Không tìm thấy script cho: $SELECTED"
    exit 1
fi
