#!/bin/bash

RC_REMOTE_NAME="Drive"
RC_INDEX_FILE="$HOME/.cache/rclone_index_${RC_REMOTE_NAME}.txt"
RC_INDEX_EXPIRY=86400

# Hàm cập nhật index (chạy ngầm)
__rc_update_index_logic() {
    if [[ ! -f "$RC_INDEX_FILE" ]] || [[ $(($(date +%s) - $(stat -c %Y "$RC_INDEX_FILE" 2>/dev/null || echo 0))) -gt $RC_INDEX_EXPIRY ]]; then
        # Đảm bảo thư mục cache tồn tại
        mkdir -p "$(dirname "$RC_INDEX_FILE")"

        # Chạy rclone update
        nohup rclone lsf "$RC_REMOTE_NAME:" --recursive --files-only \
            --fast-list --checkers 32 --retries 3 \
            --drive-pacer-min-sleep 10ms \
            --exclude 'venv/**' --exclude '.git/**' --exclude 'node_modules/**' \
            --exclude '.DS_Store' --exclude 'Thumbs.db' \
            >"$RC_INDEX_FILE" 2>/dev/null &
    fi
}

__rc_update_index() {

    mkdir -p "$(dirname "$RC_INDEX_FILE")"

    # Chạy rclone update
    rclone lsf "$RC_REMOTE_NAME:" --recursive --files-only \
        --fast-list --checkers 32 --retries 3 \
        --drive-pacer-min-sleep 10ms \
        --exclude 'venv/**' --exclude '.git/**' --exclude 'node_modules/**' \
        --exclude '.DS_Store' --exclude 'Thumbs.db' | tee "$RC_INDEX_FILE"
}

# Hàm in ra mã nguồn cho Bash Completion
__print_completion_script() {
    cat <<EOF
# Rclone Wrapper Completion Script
_rc_completions() {
    local cur prev subcommand selected
    local RC_INDEX_FILE="$RC_INDEX_FILE"
    local RC_REMOTE_NAME="$RC_REMOTE_NAME"
    
    cur="\${COMP_WORDS[COMP_CWORD]}"
    subcommand="\${COMP_WORDS[1]}"

    # Gọi update index (thông qua file thực thi chính để tái sử dụng logic)
    rc --internal-update-index

    case "\$subcommand" in
        link|ls|copy|move|cat)
            if [[ -f "\$RC_INDEX_FILE" ]]; then
                selected=\$(cat "\$RC_INDEX_FILE" | fzf --no-preview --query="\$cur" --select-1 --exit-0 --height=40% --layout=reverse --prompt="File > ")
                if [[ -n "\$selected" ]]; then
                    COMPREPLY=("\$RC_REMOTE_NAME:\$selected")
                    return 0
                fi
            fi
            ;;
        sync)
            local sync_opts=(
                "\${RC_REMOTE_NAME}:"
                "\$HOME/Documents/"
                "--dry-run"
                "--interactive"
                "--checksum"
                "--ignore-existing"
                "--transfers=16"
                "--exclude-from=\$HOME/.config/rclone/exclude.txt"
            )
            selected=\$(printf '%s\n' "\${sync_opts[@]}" | fzf --no-preview --query="\$cur" --select-1 --exit-0 --height=40% --layout=reverse --prompt="Sync Opts > ")
            if [[ -n "\$selected" ]]; then
                COMPREPLY=("\$selected")
                return 0
            fi
            ;;
        *)
            if [[ \$COMP_CWORD -eq 1 ]]; then
                local cmds="config copy sync move delete purge mkdir rmdir check ls lsd lsl md5sum sha1sum size version cleanup dedupe link help completion"
                COMPREPLY=(\$(compgen -W "\$cmds" -- "\$cur"))
            fi
            ;;
    esac
}

complete -F _rc_completions rc
EOF
}

__show_help() {
    echo "---------------------------------------------------"
    echo "  RC - Optimized Rclone Wrapper with FZF"
    echo "---------------------------------------------------"
    echo "  Usage: rc <command> [args]"
    echo ""
    echo "  Setup (Important):"
    echo "    Add the following to your .bashrc or .zshrc:"
    echo "    source <(rc completion)"
    echo ""
    echo "  Commands:"
    echo "    rc link <TAB>   : FZF search file from cached index"
    echo "    rc completion   : Generate shell completion code"
    echo "    rc update       : Update index file"
    echo "    rc help         : Show this help message"
    echo "    ...             : All other rclone commands"
    echo "---------------------------------------------------"
}

case "$1" in
completion)
    __print_completion_script
    ;;
--internal-update-index)
    __rc_update_index_logic
    ;;
help | --help)
    __show_help
    ;;
"")
    __show_help
    ;;

"update")
    __rc_update_index
    ;;
*)
    # Chạy logic update index trước khi thực thi lệnh rclone thực tế
    if [[ "$1" == "link" ]] || [[ "$1" == "ls" ]]; then
        __rc_update_index_logic
    fi
    # Chuyển tiếp toàn bộ tham số cho rclone
    rclone "$@" | tee >(wl-copy)
    ;;
esac
