#!/usr/bin/env bash

# --- Cấu hình ---
SOURCE_DIR="$HOME/Documents/[2] Obsidian/"
REMOTE_NAME="Drive:"
DEST_PATH="[2] Personal/[2] Obsidian"
LOG_FILE="$HOME/rclone-sync.log"

# --- Tham số Rclone tối ưu cho Google Drive ---
# Chúng ta sử dụng một mảng (array) để lưu các tham số. Đây là cách an toàn nhất trong bash.
rclone_params=(
    "--progress"              # Hiển thị tiến trình
    "--fast-list"             # Dùng ít API hơn để liệt kê file
    "--checkers=16"           # Số luồng kiểm tra file song song (128 là quá cao)
    "--transfers=8"           # Số luồng tải file song song (32 là quá cao cho Drive)
    "--tpslimit=10"           # Quan trọng: Tôn trọng giới hạn 10 giao dịch/giây của Google
    "--tpslimit-burst=10"     #
    "--drive-chunk-size=128M" # Kích thước khối cho file lớn (thay vì onedrive-chunk-size)
    "--buffer-size=128M"      # Bộ đệm RAM
    "--use-mmap"              # Sử dụng mmap, có thể tăng hiệu suất
    "--retries=10"            # Thử lại 10 lần nếu có lỗi
    "--retries-sleep=10s"     # Nghỉ 10 giây giữa các lần thử lại
    "--log-level=INFO"        # Cấp độ log
    "--log-file=$LOG_FILE"    # Ghi lại mọi thứ ra file log để kiểm tra

)

# --- Bắt đầu Script ---
date_start=$(date +"%d.%m.%y-%H:%M:%S")
echo "[$date_start] Bắt đầu đồng bộ..." >>"$LOG_FILE"
notify-send "Bắt đầu đồng bộ Obsidian..." "Ghi log tại: $LOG_FILE"

# --- Chạy lệnh Rclone ---
rclone sync "$SOURCE_DIR" "${REMOTE_NAME}${DEST_PATH}" "${rclone_params[@]}"

# Kiểm tra mã thoát của rclone
if [ $? -eq 0 ]; then
    # Thành công
    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    notify-send "Đồng bộ thành công!" "Hoàn tất lúc: $date_end"
    echo "[$date_end] Đồng bộ thành công." >>"$LOG_FILE"
else
    # Thất bại
    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    notify-send "LỖI ĐỒNG BỘ!" "Kiểm tra file log: $LOG_FILE"
    echo "[$date_end] Đồng bộ thất bại. Mã lỗi: $?" >>"$LOG_FILE"
fi
