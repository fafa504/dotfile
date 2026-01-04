#!/usr/bin/env bash
# Script: yay-fzf-remove
# Description: Browse and remove installed packages using fzf + yay

# Check if user passed --noconfirm as first arg
extra_args=()
if [[ "$1" == "--noconfirm" ]]; then
    extra_args=(--noconfirm)
fi

# Package selection with preview (only installed packages)
selection=$(yay -Qq | fzf -m --layout=reverse --border \
    --preview-window=bottom:70% \
    --preview 'yay -Qi {}')

# Exit if nothing selected
[[ -z "$selection" ]] && echo "No package selected." && exit 0

# Convert newline-separated selection into array (bash way)
IFS=$'\n' read -rd '' -a packages <<<"$selection"

# Remove selected packages
echo "Removing: ${packages[*]}"
yay -Rns "${extra_args[@]}" "${packages[@]}"

# Wait for user before exit
read -n 1 -s -r -p "Press any key to exit..."
echo
