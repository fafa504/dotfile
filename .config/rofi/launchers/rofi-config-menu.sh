#!/usr/bin/env bash

# Configuration
EDITOR="nvim"
CONFIG_DIR="$HOME/.config"

# Check requirements
if ! command -v rofi &>/dev/null; then
    echo "rofi is not installed" >&2
    exit 1
fi

# Get entries with icons
mapfile -t entries < <(
    find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) -print0 |
        while IFS= read -r -d '' path; do
            name=$(basename "$path")
            if [ -d "$path" ]; then
                printf "󰉋 %s\0" "$name"
            else
                printf "󰈔 %s\0" "$name"
            fi
        done | sort -z | tr '\0' '\n'
)

# Show menu
selected_entry=$(printf "%s\n" "${entries[@]}" | rofi -dmenu -i -p "󰈸 Config:")

# Exit if nothing selected
[ -z "$selected_entry" ] && exit 0

# Get clean path
clean_name=$(echo "$selected_entry" | sed 's/^[^ ]* //')
full_path="$CONFIG_DIR/$(printf '%q' "$clean_name")"

# Open based on type
if [ -d "$full_path" ]; then
    kitty --working-directory "$full_path" -e zsh -c "$EDITOR ."
else
    kitty --working-directory "$CONFIG_DIR" -e zsh -c "$EDITOR \"$clean_name\""
fi
