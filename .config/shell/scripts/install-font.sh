#!/usr/bin/env bash
# ANSI colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

install_font() {
    local font_source="$1"
    local font_name
    local font_dir="$HOME/.local/share/fonts"

    mkdir -p "$font_dir"

    if [[ "$font_source" =~ ^https?:// ]]; then
        echo -e "${BLUE}Downloading font from URL...${RESET}"
        font_name=$(basename "$font_source")
        curl -L -o "$font_dir/$font_name" "$font_source" || {
            echo -e "${RED}Failed to download font.${RESET}"
            return 1
        }
    elif [[ -f "$font_source" ]]; then
        echo -e "${BLUE}Installing font from local file...${RESET}"
        font_name=$(basename "$font_source")
        cp "$font_source" "$font_dir/$font_name" || {
            echo -e "${RED}Failed to copy font file.${RESET}"
            return 1
        }
    else
        echo -e "${YELLOW}Invalid font source: $font_source${RESET}"
        echo "Usage: install_font <url-or-local-file>"
        return 1
    fi

    if [[ "$font_name" == *.zip ]]; then
        local zip_folder_name="${font_name%.zip}"
        local extract_dir="$font_dir/$zip_folder_name"

        echo -e "${BLUE}Extracting font archive to '$extract_dir'...${RESET}"
        mkdir -p "$extract_dir"
        unzip -o "$font_dir/$font_name" -d "$extract_dir" >/dev/null 2>&1
        rm -f "$font_dir/$font_name"

        font_dir="$extract_dir"
    fi

    echo -e "${BLUE}Updating font cache...${RESET}"
    fc-cache -f "$font_dir" >/dev/null 2>&1

    echo -e "${GREEN}Font '$font_name' installed successfully in $font_dir.${RESET}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ -z "$1" ]]; then
        echo -e "${YELLOW}Usage: $0 <url-or-local-font-file>${RESET}"
        exit 1
    fi
    install_font "$1"
fi
