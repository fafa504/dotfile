#!/usr/bin/env bash

# --- Cấu hình ---
# !!! QUAN TRỌNG: Sửa đường dẫn này trỏ đến thư mục profile Firefox của bạn.
# Cách tìm: Mở about:profiles trong Firefox.
# Ví dụ: "/home/ten_ban/.mozilla/firefox/xxxxxxxx.default-release"
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox/eca2qss2.default-release"

# Cấu hình Rclone (giữ nguyên từ script của bạn)
REMOTE_NAME="Drive:"
DEST_PATH="[5] Archive/Config"
LOG_FILE="$HOME/rclone-sync.log"
CURRENT_DATE=$(date +%Y_%m_%d)

# --- Cấu hình file nén ---
# Tên file sẽ có dạng: firefox_profile_20251101_173000.tar.gz
FILENAME="($CURRENT_DATE)_firefox_profile_default.zip"
COMPRESSED_FILE_PATH="$HOME/$FILENAME"

# --- Tham số Rclone tối ưu cho Google Drive (giữ nguyên từ script của bạn) ---
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

# --- Bắt đầu Script ---
date_start=$(date +"%d.%m.%y-%H:%M:%S")
echo "========================================================" >>"$LOG_FILE"
echo "[$date_start] Bắt đầu nén và tải lên profile Firefox..." >>"$LOG_FILE"
notify-send "Bắt đầu nén Firefox..." "Profile: $FIREFOX_PROFILE_DIR"

# --- BƯỚC 0: KIỂM TRA CẤU HÌNH ---
if [ -z "$FIREFOX_PROFILE_DIR" ] || [ ! -d "$FIREFOX_PROFILE_DIR" ]; then
    echo "[$date_start] LỖI: FIREFOX_PROFILE_DIR chưa được thiết lập hoặc không tồn tại." >>"$LOG_FILE"
    echo "[$date_start] Đường dẫn không hợp lệ: '$FIREFOX_PROFILE_DIR'" >>"$LOG_FILE"
    notify-send "LỖI SCRIPT" "FIREFOX_PROFILE_DIR chưa được thiết lập. Vui lòng sửa script."
    exit 1
fi

# Tách riêng đường dẫn cha và tên thư mục profile
# Điều này giúp file .tar.gz không chứa đường dẫn tuyệt đối (/home/user/...)
# PROFILE_PARENT_DIR=$(dirname "$FIREFOX_PROFILE_DIR")
# PROFILE_NAME=$(basename "$FIREFOX_PROFILE_DIR")

# --- BƯỚC 1: NÉN PROFILE ---
echo "[$date_start] Đang nén '$PROFILE_NAME' từ '$PROFILE_PARENT_DIR'..." >>"$LOG_FILE"
echo "[$date_start] File nén sẽ được lưu tại: $COMPRESSED_FILE_PATH" >>"$LOG_FILE"

# Dùng tar để nén:
# -c: create (tạo)
# -z: gzip (nén .gz)
# -f: file (chỉ định file output)
# -C: Change directory (thay đổi thư mục gốc, để loại bỏ đường dẫn tuyệt đối)
zip -r "$COMPRESSED_FILE_PATH" "$FIREFOX_PROFILE_DIR"

# Kiểm tra xem tar có nén thành công không
if [ $? -ne 0 ]; then
    # Nén thất bại
    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    echo "[$date_end] LỖI: Nén thất bại. Vui lòng kiểm tra quyền truy cập." >>"$LOG_FILE"
    notify-send "LỖI NÉN FIREFOX!" "Kiểm tra file log: $LOG_FILE"
    # Xóa file nén (có thể bị hỏng) nếu tồn tại
    [ -f "$COMPRESSED_FILE_PATH" ] && rm "$COMPRESSED_FILE_PATH"
    exit 1
fi

echo "[$date_start] Nén thành công. Bắt đầu tải lên: $FILENAME" >>"$LOG_FILE"
notify-send "Nén Firefox hoàn tất" "Đang tải lên $FILENAME..."

# --- BƯỚC 2: TẢI LÊN BẰNG RCLONE ---
# Chúng ta dùng 'copy' thay vì 'sync' để chỉ tải file nén lên,
# không ảnh hưởng đến các file khác trong thư mục đích.
rclone copy "$COMPRESSED_FILE_PATH" "${REMOTE_NAME}${DEST_PATH}" "${rclone_params[@]}"

# --- BƯỚC 3: KIỂM TRA & DỌN DẸP ---
if [ $? -eq 0 ]; then
    # Thành công
    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    echo "[$date_end] Tải lên thành công." >>"$LOG_FILE"

    # BƯỚC 4: XÓA FILE NÉN (CHỈ KHI THÀNH CÔNG)
    echo "[$date_end] Đang xóa file nén cục bộ: $COMPRESSED_FILE_PATH" >>"$LOG_FILE"
    rm "$COMPRESSED_FILE_PATH"

    echo "[$date_end] Xóa thành công. Hoàn tất." >>"$LOG_FILE"
    notify-send "Tải lên Firefox thành công!" "Hoàn tất lúc: $date_end"
else
    # Thất bại
    date_end=$(date +"%d.%m.%y-%H:%M:%S")
    echo "[$date_end] LỖI TẢI LÊN! Mã lỗi: $?" >>"$LOG_FILE"
    echo "[$date_end] File nén $COMPRESSED_FILE_PATH SẼ ĐƯỢC GIỮ LẠI để kiểm tra." >>"$LOG_FILE"
    notify-send "LỖI TẢI LÊN!" "File nén chưa được xóa. Kiểm tra log: $LOG_FILE"
fi

echo "========================================================" >>"$LOG_FILE"
