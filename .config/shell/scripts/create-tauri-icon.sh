#!/bin/bash

# Script created on Wed  3 Dec 14:34:38 +07 2025
tauri-icon() {
    if [ -z "$1" ]; then
        echo "Usage: tauri-icon <image-path> [output-folder]"
        return 1
    fi

    local input_image="$1"
    local output_folder="${2:-.}"

    if [ ! -f "$input_image" ]; then
        echo "Error: File '$input_image' not found."
        return 1
    fi

    echo "Generating Tauri icons from '$input_image'..."
    echo "Output folder: $output_folder"

    npx @tauri-apps/cli icon "$input_image" -o "$output_folder"

    if [ $? -eq 0 ]; then
        echo "Done! Generated icons in '$output_folder':"
        ls "$output_folder"
    else
        echo "Failed to generate icons."
    fi
}

tauri-icon "$1" "$2"
