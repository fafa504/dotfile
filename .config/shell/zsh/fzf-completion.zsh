#!/usr/bin/env zsh

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

__utils_check_deps() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "[Completion Error] '$cmd' is required but not installed." >&2
            return 1
        fi
    done
    return 0
}

__utils_cleanup_kitty() {
    kitty icat --clear > /dev/tty 2>/dev/null
}

__utils_run_fzf() {
    local prompt="$1"
    local preview_cmd="$2"
    local extra_opts="$3"
    
    local fzf_opts=(
        --query="${COMP_WORDS[COMP_CWORD]}"
        --prompt="$prompt"
        --height=50%
        --reverse
        --info=inline
        --select-1
        --exit-0
    )

    if [[ -n "$preview_cmd" ]]; then
        fzf_opts+=(
            --preview="$preview_cmd"
            --layout=reverse --info=inline --height=80% --multi --cycle
            --bind 'enter:execute-silent(kitty icat --clear)+accept'
            --bind 'esc:execute-silent(kitty icat --clear)+abort'
            --bind 'ctrl-c:execute-silent(kitty icat --clear)+abort'
        )
    fi

    fzf "${fzf_opts[@]}" $extra_opts
}

EXCLUDED_DIRS=(
    .git node_modules .cache .cargo .rustup venv __pycache__ .mypy_cache
    dist build out target .idea .vscode .next .vite .local/share/Trash
    .var .flatpak .steam .thumbnails .snap .wine .android .gradle
    __pypackages__ .venv .pytest_cache .ipynb_checkpoints go/pkg
    .DS_Store coverage .scannerwork .settings
)

__utils_fd_run() {
    local base_dir="${1:-.}"
    shift
    local extra_args=("$@")

    local exclude_args=()
    for dir in "${EXCLUDED_DIRS[@]}"; do
        exclude_args+=(-E "$dir")
    done

    fd "${extra_args[@]}" "${exclude_args[@]}" . "$base_dir" 2>/dev/null
}

__source_fn_scripts() {
    local dir="$1"

    __utils_fd_run "$dir" -t f | sed 's!.*/!!'
}

__source_fn_scripts_raw() {
    local dir="$1"
    __utils_fd_run "$dir" -t f
}

__source_fn_bin_links() {
    local dir="$1"

    __utils_fd_run "$dir" -t l | sed 's!.*/!!'
}

__source_wallpapers() {
    local dir="$1"

    __utils_fd_run "$dir" -t f -e png -e jpg -e jpeg -e gif -e webp -e tiff -e bmp
}

__source_fd_files() {
    local dir="$1"
    __utils_fd_run "$dir" -t f
}

__source_fd_files_text() {
    local dir="$1"
    __utils_fd_run "$dir" -t f -H \
            --exclude '*.jpg' --exclude '*.png' --exclude '*.mp4' \
            --exclude '*.gif' --exclude '*.webp' --exclude '*.jpeg' \
            --exclude '*.zip' --exclude '*.tar.gz' --exclude '*.rar' \
            --exclude '*.iso' --exclude '*.bin' --exclude '*.exe' \
            --exclude '*.dll' --exclude '*.o' --exclude '*.so' --exclude '*.pdb' \
            --exclude '*.deb' --exclude '*.rpm' \
            --exclude '*.pdf' --exclude '*.doc' --exclude '*.docx' \
            --exclude '*.ppt' --exclude '*.pptx' \
        | sed 's/^\.\///'
}

__source_fd_directories() {
    local dir="$1"
    __utils_fd_run "$dir" -t d -H
}

_fn_fzf_completion() {
    local script_dir="$HOME/.config/shell/scripts"
    local bin_dir="$HOME/.config/shell/bin"
    local prev="${COMP_WORDS[COMP_CWORD - 1]}"
    local commands="new config alias unalias delete edit refresh sync list bin"

    local selected=""
    
    case "$prev" in
        edit|alias)
            selected=$(__source_fn_scripts "$script_dir" | \
                __utils_run_fzf "Script: " "bat --color=always --line-range :50 \"$script_dir\"/{1}")
            ;;
            
        delete)
            local raw_selection
            raw_selection=$(__source_fn_scripts_raw "$script_dir" | \
                awk '{
                    filename = gensub(".*/", "", "g", $0);
                    name_no_ext = filename; sub(/\.[^.]*$/, "", name_no_ext);
                    print name_no_ext "|" filename; 
                }' | \
                __utils_run_fzf "Delete: " "bat --color=always --line-range :50 \"$script_dir\"/{2}" "--delimiter='|' --with-nth=1")
            
            selected=$(echo "$raw_selection" | awk -F'|' '{print $1}')
            ;;

        unalias)
            selected=$(__source_fn_bin_links "$bin_dir" | \
                __utils_run_fzf "Unalias: " "bat --color=always --line-range :50 \"\$(readlink -f \"$bin_dir\"/{1})\"")
            ;;

        fn)
            COMPREPLY=($(compgen -W "$commands" -- "${COMP_WORDS[COMP_CWORD]}"))
            return 0
            ;;
    esac

    [[ -n "$selected" ]] && COMPREPLY=("$selected")
    return 0
}

_set_wallpaper_fzf_complete() {
    __utils_check_deps fzf || return 1
    
    local wp_dir="$HOME/Pictures/Wallpapers"
    [[ ! -d "$wp_dir" ]] && echo "Error: '$wp_dir' not found" >&2 && return 1

    local preview_script='$HOME/.config/shell/lib/helper/preview.sh {}'
    local selected

    selected=$(__source_wallpapers "$wp_dir" | \
        __utils_run_fzf "Select Wallpaper: " "$preview_script")

    __utils_cleanup_kitty
    [[ -n "$selected" ]] && COMPREPLY=("$selected")
    return 0
}

_open_fzf_complete() {
    __utils_check_deps fzf fd || return 1
    
    local search_path="." 
    local preview_script='$HOME/.config/shell/lib/helper/preview.sh {}'
    local selected

    selected=$(__source_fd_files "$search_path" | \
        __utils_run_fzf "Select File: " "$preview_script")

    __utils_cleanup_kitty
    [[ -n "$selected" ]] && COMPREPLY=("$selected")
    return 0
}

_cd_fzf_complete() {
    __utils_check_deps fzf fd || return 1
    
    local search_path="." 
    local preview_script='$HOME/.config/shell/lib/helper/preview.sh {}'
    local selected

    selected=$(__source_fd_directories "$search_path" | \
        __utils_run_fzf "Select File: " "$preview_script" ) 

    [[ -n "$selected" ]] && COMPREPLY=("$selected")
    return 0
}

_nvim_fzf_complete() {
    __utils_check_deps fzf fd || return 1
    
    local search_path="." 
    local preview_script='$HOME/.config/shell/lib/helper/preview.sh {}'
    local selected

    selected=$(__source_fd_files_text "$search_path" | \
        __utils_run_fzf "Select File: " "$preview_script" )

    [[ -n "$selected" ]] && COMPREPLY=("$selected")
    return 0
}

complete -F _set_wallpaper_fzf_complete set-wallpaper
# complete -F _nvim_fzf_complete nvim
complete -F _fn_fzf_completion fn
complete -F _open_fzf_complete open
# complete -F _cd_fzf_complete cd
