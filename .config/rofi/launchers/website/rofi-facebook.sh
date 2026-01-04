#!/usr/bin/env bash

# export LANG=${LANG:-en_US.UTF-8}
# export LC_ALL=${LC_ALL:-en_US.UTF-8}
# export DISPLAY=${DISPLAY:-:0}
# export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
# export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

FONT="JetBrainsMono Nerd Font 12"

OPTIONS="🌐 Facebook Homepage
👥 Cuồng Tai nghe True Wireless
👥 Gia Đình Web5Ngay
👥 Obsidian - Second Brain
👥 DUT - Đại Học Bách Khoa Đà Nẵng
🔍 Search Facebook"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "󰈹 Facebook" -font "$FONT" -matching fuzzy)

case "$CHOICE" in
"🌐 Facebook Homepage")
    xdg-open "https://www.facebook.com" &
    disown
    ;;
"🔍 Search Facebook")
    fb_query=$(rofi -dmenu -i -p "Search Facebook:" -theme "$ROFI_THEME")
    if [ -n "$fb_query" ]; then
        xdg-open "https://www.facebook.com/search/top/?q=$(printf '%s' "$fb_query" | sed 's/ /%20/g')" &
        disown
    else
        xdg-open "https://facebook.com" &
        disown
    fi
    ;;
"👥 Cuồng Tai nghe True Wireless")
    xdg-open "https://www.facebook.com/groups/750279539095674" &
    disown
    ;;
"👥 Gia Đình Web5Ngay")
    xdg-open "https://www.facebook.com/groups/2142377209324098" &
    disown
    ;;
"👥 Obsidian - Second Brain")
    xdg-open "https://www.facebook.com/groups/obsidian.secondbrain" &
    disown
    ;;

"👥 DUT - Đại Học Bách Khoa Đà Nẵng")
    xdg-open "https://www.facebook.com/groups/daihocbachkhoadanang2021" &
    disown
    ;;
*)
    echo "No valid option selected."
    ;;
esac
