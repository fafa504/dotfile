#!/usr/bin/env bash

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

FONT="JetBrainsMono Nerd Font 12"

OPTIONS="Disable CPU Boost"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "⚙️ Launcher" -font "$FONT" -matching fuzzy)

case "$CHOICE" in
"Disable CPU Boost")
    "$HOME/.config/rofi/launchers/rofi-system/disable-cpu-boost.sh"
    ;;
*) echo "No valid option selected." ;;
esac
