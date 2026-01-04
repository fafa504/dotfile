#!/usr/bin/env bash

# --- Cấu hình môi trường ---
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

# Đường dẫn file map lưu trữ dữ liệu tạm thời
MAP_FILE="$XDG_RUNTIME_DIR/anyrun_web_menu.map"

# --- Định nghĩa Danh sách (Label -> Command) ---
# Bạn có thể dễ dàng thêm bớt các mục tại đây
declare -A SCRIPTS=(
    ["󰋒 Calendar"]="xdg-open 'https://calendar.google.com'"
    ["󰚩 ChatGPT"]="xdg-open 'https://chat.openai.com'"
    ["󰚩 ChatGPT (temp)"]="xdg-open 'https://chatgpt.com/?temporary-chat=true'"
    ["󰗃 YouTube"]="xdg-open 'https://youtube.com'"
    ["󰊯 Google"]="xdg-open 'https://google.com'"
    ["󰸉 Wallpaper Heaven"]="xdg-open 'https://wallhaven.cc/'"
    [" Icons cheatsheet"]="xdg-open 'https://www.nerdfonts.com/cheat-sheet'"
    ["󰍹 Wikipedia"]="xdg-open 'https://en.wikipedia.org'"
    ["󰍹 Syncthing"]="xdg-open 'http://localhost:8384/#'"
    ["󰍹 Onedrive"]="xdg-open 'https://onedrive.live.com/?view=0'"
    ["󰋮 Messenger"]="xdg-open 'https://messenger.com'"
    ["󰋮 Zalo"]="google-chrome-stable --new-tab 'https://chat.zalo.me/'"
    ["󰊯 Shopee"]="xdg-open 'https://shopee.vn/flash_sale?'"
    [" DuckDuckGo"]="xdg-open 'https://duckduckgo.com'"
    [" GitHub"]="xdg-open 'https://github.com'"
    [" Arch Wiki"]="xdg-open 'https://wiki.archlinux.org'"
    [" Reddit"]="xdg-open 'https://reddit.com'"
    ["󰈹 Facebook"]="xdg-open 'https://facebook.com'"
    ["󰗊 Translate"]="xdg-open 'https://translate.google.com/'"
    ["󰪁 Gemini"]="xdg-open 'https://gemini.google.com/'"
    [" Copilot"]="xdg-open 'https://copilot.microsoft.com/'"
)

# --- Xử lý logic ---

# CHẾ ĐỘ 1: Liệt kê (Khi không có tham số truyền vào)
if [[ -z "$1" ]]; then
    # Xóa file map cũ và khởi tạo lại
    true >"$MAP_FILE"

    # Duyệt qua các key trong array
    for label in "${!SCRIPTS[@]}"; do
        # In nhãn ra màn hình cho Anyrun hiển thị
        echo "$label"
        # Lưu ánh xạ Label|Command vào file map
        echo "$label|${SCRIPTS[$label]}" >>"$MAP_FILE"
    done | sort

# CHẾ ĐỘ 2: Thực thi (Khi Anyrun truyền nhãn đã chọn vào $1)
else
    SELECTED_LABEL="$1"

    # Tra cứu lệnh tương ứng từ file map
    # Sử dụng grep để tìm dòng bắt đầu bằng nhãn chính xác và lấy phần sau dấu |
    COMMAND=$(grep "^$SELECTED_LABEL|" "$MAP_FILE" | cut -d'|' -f2-)

    if [[ -n "$COMMAND" ]]; then
        # Gửi thông báo
        notify-send "Anyrun" "Đang khởi chạy: $SELECTED_LABEL" --icon=web-browser

        # Thực thi lệnh bằng sh ở background
        sh -c "$COMMAND" &
        disown
    else
        notify-send "Lỗi" "Không tìm thấy lệnh cho: $SELECTED_LABEL" -u critical
        exit 1
    fi
fi
