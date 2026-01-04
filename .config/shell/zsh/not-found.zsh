command_not_found_handler() {
    printf "Command '%s' not found.\n" "$1"
    read "?Install it with yay? [Y/n] "
    if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]; then
        yay "$1" && {
            echo "Installed successfully. Running '$*'..."
            exec "$@"
        }
    else
        return 127
    fi
}

