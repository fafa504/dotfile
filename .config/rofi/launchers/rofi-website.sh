#!/usr/bin/env bash

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

FONT="JetBrainsMono Nerd Font 12"

OPTIONS="󰋒 Calendar
󰚩 ChatGPT
󰚩 ChatGPT (temp)
󰗃 YouTube
󰊯 Google
󰍹 Syncthing
󰊯 Shopee
󰍹 Wikipedia
󰋮 Messenger
󰗊 Translate
󰋮 Zalo
 DuckDuckGo
 Copilot
󰸉 Wallpaper Heaven
󰍹 Onedrive
 GitHub
 Arch Wiki
 Icons cheatsheet
󰈹 Facebook
 Reddit
󰪁 Gemini"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "🌐 Web Menu" -font "$FONT" -matching fuzzy)

case "$CHOICE" in
    "󰋒 Calendar") xdg-open "https://calendar.google.com" ;;
    "󰚩 ChatGPT") xdg-open "https://chat.openai.com" ;;
    "󰚩 ChatGPT (temp)") xdg-open "https://chatgpt.com/?temporary-chat=true" ;;
    "󰗃 YouTube")
        query=$(rofi -dmenu -i -p "🔍 Search YouTube:")
        [ -n "$query" ] && xdg-open "https://www.youtube.com/results?search_query=$query" || xdg-open "https://youtube.com"
        ;;
    "󰊯 Google")
        query=$(rofi -dmenu -i -p "🔍 Search Google:")
        [ -n "$query" ] && xdg-open "https://www.google.com/search?q=$query" || xdg-open "https://google.com"
        ;;
    "󰸉 Wallpaper Heaven")
        xdg-open "https://wallhaven.cc/"
        ;;

    " Icons cheatsheet")
        xdg-open "https://www.nerdfonts.com/cheat-sheet"
        ;;
    "󰍹 Wikipedia")
        query=$(rofi -dmenu -i -p "🔍 Search Wikipedia:")
        [ -n "$query" ] && xdg-open "https://en.wikipedia.org/w/index.php?search=$query" || xdg-open "https://en.wikipedia.org"
        ;;
    "󰍹 Syncthing")
        xdg-open "http://localhost:8384/#"
        ;;
    "󰍹 Onedrive")
        xdg-open "https://onedrive.live.com/?view=0"
        ;;

    "󰋮 Messenger")
        xdg-open "https://messenger.com"
        ;;
    "󰋮 Zalo")
        google-chrome-stable --new-tab "https://chat.zalo.me/"
        ;;
    "󰊯 Shopee")
        # query=$(rofi -dmenu -i -p "🔍 Search Shopee:")
        # [ -n "$query" ] && xdg-open "https://shopee.vn/search?keyword=$query" || xdg-open ""https://shopee.vn/flash_sale?""
        xdg-open "https://shopee.vn/flash_sale?"
        ;;
    " DuckDuckGo")
        query=$(rofi -dmenu -i -p "🔍 Search DuckDuckGo:")
        [ -n "$query" ] && xdg-open "https://duckduckgo.com/?q=$query" || xdg-open "https://duckduckgo.com"
        ;;
    " GitHub")
        query=$(rofi -dmenu -i -p "🔍 Search GitHub:")
        [ -n "$query" ] && xdg-open "https://github.com/search?q=$query" || xdg-open "https://github.com"
        ;;
    " Arch Wiki")
        query=$(rofi -dmenu -i -p "🔍 Search Arch Wiki:")
        [ -n "$query" ] && xdg-open "https://wiki.archlinux.org/index.php?search=$query" || xdg-open "https://wiki.archlinux.org"
        ;;
    " Reddit")
        query=$(rofi -dmenu -i -p "🔍 Search Reddit:")
        [ -n "$query" ] && xdg-open "https://www.reddit.com/search/?q=$query" || xdg-open "https://reddit.com"
        ;;
    "󰈹 Facebook")
        "$HOME/.config/rofi/launchers/website/rofi-facebook.sh"
        ;;
    "󰗊 Translate")
        xdg-open "https://translate.google.com/"
        ;;
    "󰪁 Gemini")
        xdg-open "https://gemini.google.com/"
        ;;

    " Copilot") "https://copilot.microsoft.com/" ;;
    "") ;;
    *) firefox --new-tab --url "$CHOICE" ;;
esac
