#!/usr/bin/env bash

# Toggle giữa layout English (xkb:us::eng) và Tiếng Việt (Unikey, mozc, anthy ...)

# Lấy engine hiện tại
current=$(ibus engine)

# Engine bạn muốn toggle
EN="BambooUs"
VI="Bamboo" # đổi thành ibus-unikey, mozc, anthy... tùy cài đặt

if [[ "$current" == "$EN" ]]; then
    ibus engine "$VI"
    notify-send "IBus" "Switched to Vietnamese ($VI)"
else
    ibus engine "$EN"
    notify-send "IBus" "Switched to English ($EN)"
fi
