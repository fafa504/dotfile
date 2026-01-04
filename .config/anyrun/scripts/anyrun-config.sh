#!/usr/bin/env bash

# --- CẤU HÌNH ---
EDITOR="nvim"
CONFIG_DIR="$HOME/.config"
MAP_FILE="$XDG_RUNTIME_DIR/anyrun_config_map.txt"

# Thiết lập môi trường Wayland/Display
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Khởi tạo mảng liên hợp
declare -A SCRIPTS

# --- HÀM HỖ TRỢ ---

# Hàm quét và tạo danh sách
generate_map() {
    # Làm trống file map cũ
    : >"$MAP_FILE"

    # Tìm kiếm các file/thư mục trong CONFIG_DIR
    while IFS= read -r -d '' path; do
        name=$(basename "$path")

        if [ -d "$path" ]; then
            label="󰉋 $name"
            # Lệnh thực thi cho thư mục
            cmd="kitty --working-directory \"$path\" -e zsh -c \"$EDITOR .\""
        else
            label="󰈔 $name"
            # Lệnh thực thi cho file
            cmd="kitty --working-directory \"$CONFIG_DIR\" -e zsh -c \"$EDITOR \\\"$name\\\"\""
        fi

        # In nhãn ra cho Anyrun (Chế độ 1)
        echo "$label"

        # Lưu vào file map: label|command
        echo "$label|$cmd" >>"$MAP_FILE"

    done < <(find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) -print0 | sort -z)
}

# --- XỬ LÝ CHÍNH ---

if [ -z "$1" ]; then
    # CHẾ ĐỘ 1: LIỆT KÊ (Anyrun gọi để lấy danh sách)
    generate_map
else
    # CHẾ ĐỘ 2: THỰC THI (Anyrun trả về kết quả đã chọn qua $1)
    SELECTED_LABEL="$1"

    # Truy xuất lệnh từ file map
    # Dùng grep với -m 1 để lấy kết quả đầu tiên khớp chính xác
    EXEC_CMD=$(grep "^$SELECTED_LABEL|" "$MAP_FILE" | cut -d'|' -f2-)

    if [ -n "$EXEC_CMD" ]; then
        notify-send -a "Anyrun Config" "Đang mở cấu hình" "$SELECTED_LABEL"

        sh -c "$EXEC_CMD" &
        disown
    else
        notify-send -u critical "Lỗi" "Không tìm thấy lệnh cho: $SELECTED_LABEL"
        exit 1
    fi
fi
