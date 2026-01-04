#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <icon_archive>"
    echo "Supported formats: .zip, .tar.gz, .tgz, .tar.xz, .tar.bz2"
    exit 1
fi

INPUT_FILE="$1"
ICON_DIR="${HOME}/.local/share/icons"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File '$INPUT_FILE' not found." >&2
    exit 1
fi

# 1. Determine the name for the new subdirectory (Input filename without extension)
BASE_NAME=$(basename "$INPUT_FILE")
# Remove common archive extensions (this is a simplified approach)
THEME_NAME="${BASE_NAME%.zip}"
THEME_NAME="${THEME_NAME%.tar.gz}"
THEME_NAME="${THEME_NAME%.tgz}"
THEME_NAME="${THEME_NAME%.tar.xz}"
THEME_NAME="${THEME_NAME%.tar.bz2}"
THEME_NAME="${THEME_NAME%.tar}"

TARGET_THEME_DIR="${ICON_DIR}/${THEME_NAME}"

# 2. Prepare the installation directory
mkdir -p "$TARGET_THEME_DIR"

echo "Installing '$INPUT_FILE' to '$TARGET_THEME_DIR'..."

case "$INPUT_FILE" in
*.zip)
    if ! command -v unzip >/dev/null; then
        echo "Error: 'unzip' is not installed." >&2
        exit 1
    fi
    # Extract contents into the newly created subdirectory
    unzip -q -o "$INPUT_FILE" -d "$TARGET_THEME_DIR"
    ;;
*.tar.gz | *.tgz)
    tar -xzf "$INPUT_FILE" -C "$TARGET_THEME_DIR"
    ;;
*.tar.xz)
    tar -xJf "$INPUT_FILE" -C "$TARGET_THEME_DIR"
    ;;
*.tar.bz2)
    tar -xjf "$INPUT_FILE" -C "$TARGET_THEME_DIR"
    ;;
*)
    echo "Error: Unsupported file extension." >&2
    rmdir "$TARGET_THEME_DIR" 2>/dev/null || true # Cleanup the empty dir if extraction fails early
    exit 1
    ;;
esac

# 3. Update KDE system configuration cache
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 --noincremental >/dev/null 2>&1
fi

echo "Done. Theme installed as '$THEME_NAME'."
echo "Open System Settings > Appearance > Icons to apply."
