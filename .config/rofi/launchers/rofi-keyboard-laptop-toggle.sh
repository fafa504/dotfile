#!/bin/bash

# Define the directory where your executable scripts are located
# This should be the FOLDER containing the scripts you want to select and run.
SCRIPT_DIR="$HOME/.config/rofi/launchers/helper"

# --- Rofi Selection Logic ---

# 1. List all executable files in the directory.
#    -maxdepth 1: Prevents searching subdirectories.
#    -type f -executable: Finds files that are executable.
#    -printf "%f\n": Prints only the filename (not the full path).
# 2. Pipe the list to Rofi (-dmenu mode).
#    -dmenu: Uses Rofi as a dmenu replacement for selection.
#    -i: Case insensitive matching.
#    -p "Select Command (PKEXEC Required)": Sets the prompt text.
SELECTED_FILE=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -executable -printf "%f\n" | rofi -dmenu -i -p "Select Command (PKEXEC Required)")

# Check if a file was selected (i.e., the user didn't press Esc or cancel)
if [ -z "$SELECTED_FILE" ]; then
    echo "No file selected. Exiting."
    exit 0
fi

# Construct the full path to the selected script
TARGET_SCRIPT="$SCRIPT_DIR/$SELECTED_FILE"

# --- Execution Logic (Using pkexec for Graphical Auth) ---

# Execute the target script using pkexec.
# pkexec is the standard way to trigger a graphical password window (via PolicyKit)
# on modern desktop environments like Gnome, KDE, etc.
echo "Attempting to run: $TARGET_SCRIPT with pkexec..."
pkexec "$TARGET_SCRIPT"

# Check the exit status of the pkexec command
if [ $? -eq 0 ]; then
    notify-send "Successfully ran $SELECTED_FILE with elevated privileges."
else
    notify-send "Execution failed or was cancelled (Authentication failure or script error)."
fi
