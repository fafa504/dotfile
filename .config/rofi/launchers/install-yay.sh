#!/usr/bin/env bash
# Script: yay-fzf-install
# Description: Browse and install packages using fzf + yay

# Check if user passed --noconfirm as first arg
extra_args=()
if [[ "$1" == "--noconfirm" ]]; then
    extra_args=(--noconfirm)
fi

# Package selection with preview
selection=$(yay -Slq | fzf -m --layout=reverse --border \
    --preview-window=bottom:70% \
    --preview 'yay -Si {}')

# Exit if nothing selected
[[ -z "$selection" ]] && echo "No package selected." && exit 0

# Convert newline-separated selection into array (bash way)
IFS=$'\n' read -rd '' -a packages <<<"$selection"

# Install selected packages
echo "Installing: ${packages[*]}"
yay -S "${extra_args[@]}" "${packages[@]}"

# Wait for user before exit
read -n 1 -s -r -p "Press any key to exit..."
echo
