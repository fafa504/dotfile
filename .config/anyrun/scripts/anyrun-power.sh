#!/usr/bin/env bash

# Cấu hình file ánh xạ tạm thời
MAP_FILE="${XDG_RUNTIME_DIR}/anyrun-power.sh"

declare -A SCRIPTS=(
    ["Shutdown"]="systemctl poweroff"
    ["Reboot"]="systemctl reboot"
    ["Lock Screen"]="swaylock"
    ["Suspend"]="systemctl suspend"
    ["Logout"]="hyprctl dispatch exit"
)

# Chế độ 1: Liệt kê danh sách (Không có tham số đầu vào)
if [ -z "$1" ]; then
    # Xóa file map cũ và tạo mới
    >"$MAP_FILE"

    for label in "${!SCRIPTS[@]}"; do
        # In nhãn ra cho Anyrun hiển thị
        echo "$label"
        # Lưu ánh xạ vào file (label|path)
        echo "${label}|${SCRIPTS[$label]}" >>"$MAP_FILE"
    done

# Chế độ 2: Thực thi (Có tham số đầu vào từ Anyrun)
else
    CHOICE="$1"

    # Tìm đường dẫn script từ file map dựa trên nhãn đã chọn
    SCRIPT_PATH=$(grep "^${CHOICE}|" "$MAP_FILE" | cut -d'|' -f2-)

    if [ -n "$SCRIPT_PATH" ]; then
        # Thông báo qua notify-send (Wayland compatible)
        notify-send "Anyrun" "Executing: $CHOICE" -i system-run

        # Thực thi script ở background với các biến môi trường cần thiết
        export DISPLAY=${DISPLAY:-:0}
        export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}

        sh -c "$SCRIPT_PATH" &
    else
        notify-send "Anyrun Error" "Could not find script for: $CHOICE" -u critical
    fi
fi
