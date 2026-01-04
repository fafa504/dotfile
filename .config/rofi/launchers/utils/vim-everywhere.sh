#!/bin/bash

# 1. Tạo đường dẫn tệp tạm
tmpfile="/tmp/vim-anywhere-$$.txt"

# 2. Thiết lập bẫy (trap) để dọn dẹp
trap 'rm -f "$tmpfile"; exit' EXIT INT TERM

# 3. Tạo tệp rỗng
touch "$tmpfile"

# 4. Chạy alacritty và nvim
# Script sẽ dừng tại đây cho đến khi bạn đóng Alacritty
alacritty -e nvim "$tmpfile"

# 5. Kiểm tra nội dung và thực hiện sao chép + dán
if [ -s "$tmpfile" ]; then
    # Sao chép vào clipboard
    if command -v wl-copy >/dev/null; then
        cat "$tmpfile" | wl-copy
    elif command -v xclip >/dev/null; then
        cat "$tmpfile" | xclip -selection clipboard
    fi

    # 6. Gọi ydotool thực hiện lệnh paste (Ctrl+V)
    # Thêm sleep nhỏ (0.2s) để đảm bảo cửa sổ mục tiêu đã được focus lại
    if command -v ydotool >/dev/null; then
        sleep 0.2
        ydotool key 29:1 47:1 47:0 29:0 # Ctrl_L (29) + V (47)
    else
        echo "Cảnh báo: ydotool chưa được cài đặt."
    fi
fi
