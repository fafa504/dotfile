#!/usr/bin/env bash

export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

MAP_FILE="$XDG_RUNTIME_DIR/anyrun_launcher_map.tmp"

declare -A LAUNCHER_MAP
LAUNCHER_MAP=(
    ["Ibus daemon"]="$HOME/.config/rofi/launchers/rofi-ibus-daemon.sh"
    ["Wi-Fi"]="$HOME/.config/rofi/launchers/rofi-wifi-menu.sh"
    ["Preview Markdown"]="$HOME/.config/rofi/launchers/utils/markdown-preview-clipboard.sh"
    ["Yay install"]="alacritty -e zsh -c '~/.config/rofi/launchers/install-yay.sh'"
    ["Yay install (noconfirm)"]="alacritty -e zsh -c '~/.config/rofi/launchers/install-yay.sh --noconfirm'"
    ["Yay uninstall"]="alacritty -e zsh -c '~/.config/rofi/launchers/uninstall-yay.sh'"
    ["2025"]="xdg-open '/home/mintori/Documents/[2] Obsidian/05_Personal/03-Finance/2025/Month-12.xlsx'"
    ["Bluetooth Menu"]="$HOME/.config/rofi/launchers/rofi-bluetooth.sh"
    ["Boot to Windows"]="$HOME/.config/rofi/launchers/rofi-boot-to-windows.sh"
    ["Keyboard Enable"]="$HOME/.config/rofi/launchers/rofi-keyboard-laptop-toggle.sh"
    ["Power Menu"]="$HOME/.config/rofi/launchers/rofi-power-menu.sh"
)

# 3. Chế độ 1: Liệt kê (Khi không có tham số)
if [ -z "$1" ]; then
    # Xóa file map cũ và khởi tạo lại
    >"$MAP_FILE"

    for label in "${!LAUNCHER_MAP[@]}"; do
        # In nhãn ra Anyrun UI
        echo "$label"
        # Lưu mapping vào file tạm: Label|Command
        echo "$label|${LAUNCHER_MAP[$label]}" >>"$MAP_FILE"
    done
    exit 0
fi

# 4. Chế độ 2: Thực thi (Khi có tham số $1)
SELECTED_LABEL="$1"

# Tra cứu lệnh từ file map dựa trên label người dùng chọn
if [[ -f "$MAP_FILE" ]]; then
    # Dùng grep để tìm dòng tương ứng và cut để lấy phần lệnh (sau dấu |)
    CMD=$(grep "^$SELECTED_LABEL|" "$MAP_FILE" | cut -d'|' -f2-)
fi

# Kiểm tra và thực thi
if [[ -n "$CMD" ]]; then
    # notify-send "Anyrun Launcher" "Đang khởi chạy: $SELECTED_LABEL" -i system-run-symbolic

    # Thực thi lệnh ở background
    eval "$CMD &"
    exit 0
else
    notify-send "Error" "Không tìm thấy lệnh cho: $SELECTED_LABEL" -u critical
    exit 1
fi
