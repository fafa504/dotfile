#!/usr/bin/env bash

copy=false
[[ "$1" == "copy" ]] && copy=true

DIR="$HOME/Documents/[2] Obsidian/06_Script/Prompt"
if [[ ! -d "$DIR" ]]; then
    echo "Error: '$DIR' is not a directory"
    exit 1
fi

FILE=$(find "$DIR" -maxdepth 1 -type f -name "*.md" -printf "%f\n" |
    sed 's/\.md$//' |
    rofi -dmenu -p "Select file")

[[ -z "$FILE" ]] && exit 0

FULL_PATH="$DIR/$FILE.md"
if [[ ! -f "$FULL_PATH" ]]; then
    notify-send "File does not exist!"
    exit 1
fi

if [[ "$copy" == true ]]; then
    CONTENT="$(cat "$FULL_PATH")$(wl-paste)"
else
    CONTENT="$(cat "$FULL_PATH")"
fi

printf '%s' "$CONTENT" | wl-copy
notify-send "Copied successfully!"
