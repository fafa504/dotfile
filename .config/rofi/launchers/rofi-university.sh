#!/usr/bin/env bash

FONT="JetBrainsMono Nerd Font 12"

# Thư mục gốc
BASE_DIR="$HOME/Documents/[2] Obsidian/02_University/Year 3/Semester 05"

# Lấy danh sách tên thư mục con (1 cấp)
folders=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

# Nếu không có thư mục thì thoát
[ -z "$folders" ] && exit 1

# Dùng rofi để chọn folder theo tên (với theme, font, fuzzy)
chosen=$(echo "$folders" | rofi -dmenu \
    -i \
    -p "Open folder:" \
    -matching fuzzy \
    -font "$FONT")

# Nếu không chọn thì thoát
[ -z "$chosen" ] && exit 0

# Mở kitty trong folder đã chọn
kitty --working-directory "$BASE_DIR/$chosen" zsh -c "eza --tree --icons --git --level=1; exec zsh"
