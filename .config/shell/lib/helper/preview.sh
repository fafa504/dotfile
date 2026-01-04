#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

get_mime() {
    local FILE="$1"
    if [[ -d "$FILE" ]]; then
        echo "directory"
        return
    fi

    local extension="${FILE##*.}"
    extension="${extension,,}" # lowercase

    local MIME=""

    case "$extension" in
    svg | jpg | jpeg | png | gif | bmp | webp | tiff) MIME="image/$extension" ;;
    mp4 | mkv | mov | webm | avi) MIME="video/$extension" ;;
    pdf) MIME="application/pdf" ;;
    *) MIME="text/plain" ;;
    esac

    echo "$MIME"
}

preview_file() {
    local FILE="$1"
    local MIME
    MIME=$(get_mime "$FILE")

    case "$MIME" in
    image/*)
        if command -v kitty >/dev/null 2>&1; then
            kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$FILE"
        elif command -v chafa >/dev/null 2>&1; then
            chafa "$FILE"
        else
            echo "Image preview requires kitty or chafa."
        fi
        ;;
    video/*)
        tmp=$(mktemp --suffix=.png)
        if ! ffmpeg -y -i "$FILE" -map 0:v:1 -vframes 1 "$tmp" 2>/dev/null; then
            ffmpeg -y -i "$FILE" -vframes 1 -an -q:v 2 "$tmp" >/dev/null 2>&1
        fi
        if command -v kitty >/dev/null 2>&1; then
            kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$tmp"
        elif command -v chafa >/dev/null 2>&1; then
            chafa "$tmp"
        else
            echo "Video preview requires kitty or chafa."
        fi
        rm -f "$tmp"
        ;;
    application/pdf)
        tmp=$(mktemp --suffix=.png)
        pdftoppm -singlefile -png "$FILE" "${tmp%.png}" >/dev/null 2>&1
        if command -v kitty >/dev/null 2>&1; then
            kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "${tmp%.png}.png"
        elif command -v chafa >/dev/null 2>&1; then
            chafa "${tmp%.png}.png"
        else
            echo "PDF preview requires kitty or chafa."
        fi
        rm -f "${tmp%.png}.png"
        ;;
    text/*)
        if command -v bat >/dev/null 2>&1; then
            bat --style=full,grid --color=always --pager=less "$FILE"
        else
            cat "$FILE"
        fi

        if command -v kitty >/dev/null 2>&1; then
            kitty icat --clear
        fi
        ;;
    directory)
        if command -v eza >/dev/null 2>&1; then
            eza --tree --icons --git --level=3 --color=always "$FILE"
        else
            ls -lh "$FILE"
        fi

        if command -v kitty >/dev/null 2>&1; then
            kitty icat --clear
        fi
        ;;

    *)
        echo "No preview available for $FILE ($MIME)"
        ;;
    esac
}

# Usage
TYPE="${1:-}"
preview_file "$TYPE"
