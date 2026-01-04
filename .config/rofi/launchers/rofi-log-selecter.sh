#!/bin/bash

FONT="JetBrainsMono Nerd Font 12"

# Options with icons
options="Rclone
"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Log" -font "$FONT")

# Execute the chosen option
case "$chosen" in
"Rclone")
    xdg-open "$HOME/rclone-sync.log"
    ;;
esac
