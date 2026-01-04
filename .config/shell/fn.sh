#!/usr/bin/env bash

# --- CONFIGURATION ---
ROOT_DIR="$HOME/.config/shell"
SCRIPTS_DIR="$ROOT_DIR/scripts"
BIN_DIR="$ROOT_DIR/bin"
EDITOR=${EDITOR:-nano}

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

mkdir -p "$SCRIPTS_DIR"
mkdir -p "$BIN_DIR"

function _list() {
    eza -R1a "$1"
}

function _calculate_names() {
    local name_input="$1"
    local ext_input="$2"

    local name="$name_input"
    local filename=""

    if [[ "$name" != *.* ]]; then
        filename="${name}.${ext_input}"
    else
        filename="$name"
        name="${filename%.*}"
    fi

    echo "$filename"
    echo "$name"
}

function _create_script_content_and_set_permission() {
    local filepath="$1"
    echo "#!/bin/bash" >"$filepath"
    echo "" >>"$filepath"
    echo "# Script created on $(date)" >>"$filepath"
    chmod +x "$filepath"
}

function _create_symlink() {
    local target_path="$1"
    local link_path="$2"
    ln -sf "$target_path" "$link_path"
}

function _find_existing_target() {
    local source_file_input="$1"

    if [[ -f "$SCRIPTS_DIR/$source_file_input" ]]; then
        echo "$SCRIPTS_DIR/$source_file_input"
        return 0
    fi

    local found=$(find "$SCRIPTS_DIR" -maxdepth 1 -name "${source_file_input}.*" -print -quit)
    if [[ -n "$found" ]]; then
        echo "$found"
        return 0
    fi

    return 1
}

function _confirm_and_delete() {
    local name=$1
    local linkpath=$2
    local target_file=$3

    echo -e "${YELLOW}You are about to delete:${NC}"
    echo "  1. Symlink: $linkpath"
    echo "  2. Target File: $target_file"
    read -p "Are you sure? (y/N): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm "$linkpath"
        if [[ -f "$target_file" ]]; then
            rm "$target_file"
        fi
        info "Deletion successful."
    else
        info "Operation cancelled."
    fi
}

function cmd_init() {
    local name="$ROOT_DIR/fn.sh"
    local filename="${name%.*}"
    local target_path="$ROOT_DIR/$name"
    local linkpath="$BIN_DIR/$filename"
    if [[ -L "$linkpath" ]]; then
        warn "Command '$name' is already initialized. Skipping."
        return 0
    fi
    chmod +x "$target_path"
    ln -sf "$target_path" "$linkpath"
    info "Successfully initialized command '$filename'."
    info "You can now call '$filename' from anywhere after reloading the shell."
}

function cmd_config() {
    local filepath="$ROOT_DIR/fn.sh"
    cd "$ROOT_DIR"
    $EDITOR "$filepath"
}

function cmd_new() {
    local name_input=$1
    local ext_input="sh"

    if [[ -z "$name_input" ]]; then
        error "Please enter a script name. Example: fn new my-script"
        exit 1
    fi

    local names=($(_calculate_names "$name_input" "$ext_input"))
    local filename="${names[0]}"
    local name="${names[1]}"

    local filepath="$SCRIPTS_DIR/$filename"
    local linkpath="$BIN_DIR/$name"

    if [[ -f "$filepath" ]]; then
        error "File $filename already exists!"
        exit 1
    fi

    _create_script_content_and_set_permission "$filepath"
    _create_symlink "$filepath" "$linkpath"

    info "File created: $filepath"
    info "Symlink created: $name -> $filename"

    info "Opening editor..."
    $EDITOR "$filepath"
}

function cmd_alias() {
    local source_file_input=$1
    local alias_name=$2

    if [[ -z "$source_file_input" || -z "$alias_name" ]]; then
        error "Missing parameters. Usage: fn alias <source-file> <new-command-name>"
        exit 1
    fi

    local target_file=$(_find_existing_target "$source_file_input")

    if [[ -z "$target_file" ]]; then
        error "Source script not found: $source_file_input"
        exit 1
    fi

    local linkpath="$BIN_DIR/$alias_name"
    _create_symlink "$target_file" "$linkpath"

    info "Alias created: $alias_name -> $(basename "$target_file")"
}

function cmd_delete() {
    local name=$1

    if [[ -z "$name" ]]; then
        error "Please enter the command name to delete."
        exit 1
    fi

    local linkpath="$BIN_DIR/$name"

    if [[ ! -L "$linkpath" ]]; then
        error "Command (symlink) '$name' not found in bin/"
        exit 1
    fi

    local target_file=$(readlink -f "$linkpath")

    _confirm_and_delete "$name" "$linkpath" "$target_file"
}

function cmd_unalias() {
    local name=$1

    if [[ -z "$name" ]]; then
        error "Please enter the alias name to remove."
        exit 1
    fi

    local linkpath="$BIN_DIR/$name"

    if [[ -L "$linkpath" ]]; then
        rm "$linkpath"
        info "Symlink '$name' removed. Source file is preserved."
    else
        error "Symlink '$name' not found."
    fi
}

function cmd_refresh() {
    info "Refreshing all symlinks from the scripts folder..."
    for file in "$SCRIPTS_DIR"/*; do
        [[ -f "$file" ]] || continue

        local filename=$(basename "$file")
        local link_name="${filename%.*}"

        chmod +x "$file"
        _create_symlink "$file" "$BIN_DIR/$link_name"

        echo "Linked: $link_name"
    done
    info "Done."
}

function cmd_edit() {
    local filename=$1

    if [[ -z "$filename" ]]; then
        error "Please enter a filename. Example: fn edit my-script.sh"
        exit 1
    fi

    local filepath="$SCRIPTS_DIR/$filename"

    if [[ -f "$filepath" ]]; then
        $EDITOR "$filepath"
    else
        echo "Filename is not exist!"
    fi
}

# --- ARGUMENT HANDLING ---
case "$1" in
init)
    cmd_init
    ;;
config)
    cmd_config
    ;;
new)
    cmd_new "$2" "$3"
    ;;
alias)
    cmd_alias "$2" "$3"
    ;;
delete)
    cmd_delete "$2"
    ;;
unalias)
    cmd_unalias "$2"
    ;;
refresh | sync)
    cmd_refresh
    ;;
edit)
    cmd_edit "$2"
    ;;
bin)
    _list "$BIN_DIR"
    ;;
list)
    _list "$SCRIPTS_DIR"
    ;;
*)
    echo "Script Manager Utility (fn)"
    echo "Usage:"
    echo "  fn new <name>           : Creates new script + symlink + opens editor"
    echo "  fn config               : Edit bash file"
    echo "  fn alias <source> <name>: Creates a new command name pointing to an existing script"
    echo "  fn unalias <name>       : Removes symlink (preserves source file)"
    echo "  fn delete <name>        : Deletes both symlink and source script file"
    echo "  fn edit <name>          : Edit a script"
    echo "  fn refresh | sync       : Scans the scripts folder and relinks all commands"
    echo "  fn list                 : List all current scripts (scripts)"
    echo "  fn bin                  : List all current scripts (bin)"
    ;;
esac
