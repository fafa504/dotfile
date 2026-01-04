#!/usr/bin/env bash
set -euo pipefail

depth=${1:-10}

if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is not installed. Please install fzf to use this function." >&2
    return 1
fi

if ! command -v fd &>/dev/null; then
    echo "Error: fzf is not installed. Please install fzf to use this function." >&2
    return 1
fi

items_to_delete=$(fd --type f --max-depth $depth | fzf --sort --multi --height 70% --prompt="SELECT items to DELETE (Recursive): ")

if [ -z "$items_to_delete" ]; then
    echo "No items selected. Exiting deletion."
    return 0
fi

count=$(echo "$items_to_delete" | wc -l | tr -d '[:space:]')

echo -e "\n--- Selected items to delete ($count total) ---"
echo "$items_to_delete"
echo "------------------------------------------------------"

echo "$items_to_delete" | while IFS= read -r item; do
    if [ -n "$item" ]; then
        echo "-> Deleting: $item"
    fi
done

echo "$items_to_delete" | xargs -d '\n' -I {} rm -rf -- "{}"

echo -e "\nDeletion complete."
