#!/bin/bash

FONT="JetBrainsMono Nerd Font 12"

# Options with icons
options=" Shutdown\n Reboot\n Lock\n Suspend\n Logout"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -font "$FONT")

# Extract action (remove the icon)
action=$(echo $chosen | awk '{print $2}')

# Execute the chosen option
case "$action" in
Shutdown)
    systemctl poweroff
    ;;
Reboot)
    systemctl reboot
    ;;
Lock)
    i3lock
    ;;
Suspend)
    systemctl suspend
    ;;
Logout)
    pkill -KILL -u $USER
    ;;
esac
