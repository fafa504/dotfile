#!/bin/bash

EXCLUDED_DIRS=(
    .git node_modules .cache .cargo .rustup venv __pycache__ .mypy_cache
    dist build out target .idea .vscode .next .vite .local/share/Trash
    .var .flatpak .steam .thumbnails .snap .wine .android .gradle
    __pypackages__ .venv .pytest_cache .ipynb_checkpoints go/pkg .java
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
        --exclude '*.ppt' --exclude '*.pptx' |
        sed 's/^\.\///'
}

__utils_check_deps() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "[Completion Error] '$cmd' is required but not installed." >&2
            return 1
        fi
    done
    return 0
}

# Lấy danh sách file dùng fd
__source_fd_files() {
    local dir="$1"
    fd -t f . "$dir" 2>/dev/null
}

ZSH_FUNC_DIR="$HOME/.config/shell/functions"
if [ -d "$ZSH_FUNC_DIR" ]; then
    fpath=("$ZSH_FUNC_DIR" $fpath)
    autoload -Uz "$ZSH_FUNC_DIR"/*(:t)
fi

UnzipAll() {
    DIR="${1:-.}"

    for zipfile in "$DIR"/*.zip; do
        # Bỏ qua nếu không có file nào
        [ -e "$zipfile" ] || continue

        echo "🗂️  Giải nén: $zipfile"
        unzip -o "$zipfile" -d "$DIR" && rm -f "$zipfile"
    done

    echo "✅ Hoàn tất."
}

function lt() {
    local level="${1:-0}"
    eza --tree --level="$level"
}

sync_config() {
    local dest="Drive:[5] Archive/Config/Linux/"
    local file_list="$HOME/.config/rclone/filter/config.txt"

    rclone copy --filter-from="$file_list" "$HOME" "$dest" \
        "${rclone_params[@]}" &&
        notify-send "Sync Complete" "Linux config backup to Google Drive succeeded!" ||
        notify-send "Sync Failed" "Check rclone logs for details."
}

current_folder_name() {
    echo "${PWD##*/}"
}

today() {
    echo "$(date +"%Y_%m_%d")"
}

# IP public
myip() {
    curl -s ifconfig.me
}

# Kiểm tra port đang nghe
ports() {
    sudo lsof -i -P -n | grep LISTEN
}

# Tìm package đang chiếm port
whoport() {
    sudo lsof -i :$1
}

genpass() {
    local len=${1:-16}
    tr -dc 'A-Za-z0-9!@#$%^&*()_+=' </dev/urandom | head -c "$len"
    echo
}

pioinit() {
    cp -rf /home/mintori/.config/mintori/pio-init/* . || {
        echo "Failed to copy init files"
        return 1
    }

    if [[ -f platformio.ini ]]; then
        if ! grep -q "extra_scripts *= *pre:gen_compile_commands.py" platformio.ini; then
            echo "" >>platformio.ini
            echo "extra_scripts = pre:gen_compile_commands.py" >>platformio.ini
            echo "monitor_speed = 9600" >>platformio.ini
            echo "monitor_port = /dev/ttyUSB0" >>platformio.ini
            echo "✅ Added extra_scripts to platformio.ini"
        else
            echo "ℹ️ platformio.ini already contains extra_scripts"
        fi
    fi

    # Ensure src directory exists
    mkdir -p src

    # Create main.cpp if it doesn't exist
    if [[ ! -f src/main.cpp ]]; then
        cat >src/main.cpp <<'EOF'
#include <Arduino.h>

void setup() {
    // put your setup code here, to run once:
}

void loop() {
    // put your main code here, to run repeatedly:
}
EOF
        echo "✅ Created src/main.cpp"
    else
        echo "ℹ️ src/main.cpp already exists, skipped creation"
    fi

    # Run PlatformIO target
    pio run -t compiledb
}

# Transcode a video to a good-balance 1080p that's great for sharing online
transcode-video-1080p() {
    ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K that's great for sharing online
transcode-video-4K() {
    ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Transcode any image to JPG image that's great for shrinking wallpapers
img2jpg() {
    magick $1 -quality 95 -strip ${1%.*}.jpg
}

# Transcode any image to JPG image that's great for sharing online without being too big
img2jpg-small() {
    magick $1 -resize 1080x\> -quality 95 -strip ${1%.*}.jpg
}

# Transcode any image to compressed-but-lossless PNG
img2png() {
    magick "$1" -strip -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        "${1%.*}.png"
}

lt() {
    level=${1:-1}
    eza --tree --icons --git --level="$level"
}

nf() {
    local file

    file=$(__source_fd_files_text "." |
        fzf --height=90% --layout=reverse --info=inline) || return

    [ -n "$file" ] || return
    nvim -- "$file"
}

sunf() {
    local file

    file=$(__source_fd_files_text "." |
        fzf --height=90% --layout=reverse --info=inline) || return

    [ -n "$file" ] || return
    sudoedit -- "$file"
}

sleep_after() {
    local minutes=$1

    if [[ -z "$minutes" || "$minutes" -le 0 ]]; then
        echo "!> Vui lòng nhập số phút hợp lệ. Ví dụ: sleep_after 10"
        return 1
    fi

    local seconds=$((minutes * 60))

    while ((seconds > 0)); do
        echo -ne "💤 Tắt máy sau: $((seconds / 60)) phút $(printf '%02d' $((seconds % 60))) giây\r"

        if ((seconds == 300)); then
            notify-send "Thông báo" "Máy sẽ ngủ sau 5 phút."
        fi

        sleep 1
        ((seconds--))
    done

    echo -e "\n💤 Đang đưa máy vào chế độ ngủ..."
    notify-send "Đang ngủ..." "Hệ thống đang chuyển sang chế độ Sleep."
    systemctl suspend
}

v() {
    nvim "$*"
}
vi() {
    trans -t vi "$*"
}
en() {
    trans -t en "$*"
}

google() {
    local query_string
    query_string=$(echo "$@" | tr ' ' '+')
    local search_url="https://www.google.com/search?q=${query_string}"
    xdg-open "$search_url" &>/dev/null &
    echo "Đang tìm kiếm trên Google: '$@'"
}

open() {
    if [[ "$#" -gt 0 ]]; then
        for file in "$@"; do
            xdg-open "$file" >/dev/null 2>&1 &
        done
        return 0
    fi
    __utils_check_deps fzf fd || return 1
    local selected=$(__source_fd_files "." | fzf)

    kitty icat --clear >/dev/tty 2>/dev/null
    echo $selected
    [ -n "$selected" ] && xdg-open "$selected"
}

ja() {
    trans -t ja "$*"
}

disable_cpu_boost() {
    echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
}

nw() {
    nvim $(which $1)
}

cd() {
    if [ "$#" -eq 0 ]; then
        local selected_dir
        selected_dir=$(
            fd -t d -H --max-depth 10 "." |
                FZF_DEFAULT_OPTS="" fzf --preview 'eza --tree --icons --git --level=3 --color=always {}' --prompt="fzf-cd: " --cycle
        )

        if [ -n "$selected_dir" ]; then
            builtin cd "$selected_dir"
        fi

    else
        builtin cd "$@"
    fi
}

play_music() {
    mpv "https://www.youtube.com/watch?v=qwdzIECTqn8&t=27885s"
}

cargo-run() {
    cargo watch -x run
}
