#!/usr/bin/env bash

SOURCE_DIR="$HOME/Documents/[2] Obsidian/"
REMOTE_NAME="Drive:"
DEST_PATH="[2] Personal/[2] Obsidian"
LOG_FILE="$HOME/rclone-sync.log"

DEBOUNCE_TIME=10

rclone_params=(
    "--progress"
    "--fast-list"
    "--checkers=16"
    "--transfers=8"
    "--tpslimit=10"
    "--tpslimit-burst=10"
    "--drive-chunk-size=128M"
    "--buffer-size=128M"
    "--use-mmap"
    "--retries=10"
    "--retries-sleep=10s"
    "--log-level=INFO"
    "--log-file=$LOG_FILE"
)

sync_now() {
    date_start=$(date +"%d.%m.%y-%H:%M:%S")
    echo "[$date_start] 🔄 Bắt đầu đồng bộ..." >>"$LOG_FILE"
    notify-send "Đồng bộ Obsidian" "Bắt đầu đồng bộ…"

    rclone sync "$SOURCE_DIR" "${REMOTE_NAME}${DEST_PATH}" "${rclone_params[@]}"
    status=$?

    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    if [ $status -eq 0 ]; then
        echo "[$date_end] Đồng bộ thành công." >>"$LOG_FILE"
        notify-send "Đồng bộ thành công!" "Hoàn tất lúc: $date_end"
    else
        echo "[$date_end] Đồng bộ thất bại. Mã lỗi: $status" >>"$LOG_FILE"
        notify-send "Lỗi đồng bộ!" "Kiểm tra log: $LOG_FILE"
    fi
}

echo "Bắt đầu giám sát: $SOURCE_DIR"
notify-send "Obsidian Sync" "Đang giám sát thay đổi trong: $SOURCE_DIR"

# Chạy inotifywait vĩnh viễn
inotifywait -m -r -e create,modify,delete,move "$SOURCE_DIR" --format '%w%f' |
    while read -r changed_file; do
        echo "Phát hiện thay đổi: $changed_file" >>"$LOG_FILE"

        # Nếu có thay đổi mới, reset lại timer debounce
        if [[ -n "$timer_pid" && -e /proc/$timer_pid ]]; then
            kill "$timer_pid" 2>/dev/null
        fi

        (
            sleep $DEBOUNCE_TIME
            sync_now
        ) &
        timer_pid=$!
    done
