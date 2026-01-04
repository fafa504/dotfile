#!/usr/bin/env bash

# Hàm để giải nén thủ công và cài đặt nội dung gói RPM.
# Hàm này đã được sửa để xử lý các gói RPM có Payload nén bằng Gzip.
install_rpm() {
    # Gán đối số 1 ($1) vào biến rpm_file
    local rpm_file="$1"
    # Gán đối số 2 ($2) vào biến dest_dir, mặc định là 'extracted_rpm' nếu không có đối số 2
    local dest_dir="${2:-extracted_rpm}"
    local script_name="$(basename "$0")"

    # --- 1. Kiểm tra Đầu vào ---
    if [ -z "$rpm_file" ]; then
        echo "Usage: $script_name <path-to-rpm-file> [destination-folder]" >&2
        return 1
    fi

    if [ ! -f "$rpm_file" ]; then
        echo "Error: File not found: $rpm_file" >&2
        return 1
    fi

    # --- 2. Chuẩn bị Thư mục ---
    if ! mkdir -p "$dest_dir"; then
        echo "Error: Could not create destination directory $dest_dir" >&2
        return 1
    fi

    echo "--- Starting RPM Manual Installation ---"
    echo "RPM File: $rpm_file"
    echo "Target Directory: $dest_dir"

    # --- 3. Giải nén Nội dung RPM (SỬA LỖI GZIP) ---
    echo "Extracting content using rpm2cpio, gunzip, and cpio..."

    # Sao chép tệp RPM vào thư mục đích (Tùy chọn, để đảm bảo rpm2cpio tìm thấy nó)
    cp "$rpm_file" "$dest_dir"

    # Thực hiện giải nén:
    # 1. rpm2cpio trích xuất Payload nén Gzip.
    # 2. gunzip -c giải nén Gzip và đưa luồng CPIO thô vào pipe.
    # 3. cpio -idmv giải nén các tệp CPIO vào thư mục hiện tại ($dest_dir).
    if ! (cd "$dest_dir" && rpm2cpio "$rpm_file" | gunzip -c | cpio -idmv); then
        echo "Error: Extraction failed." >&2
        echo "This may indicate an issue with the RPM file or missing 'gunzip'." >&2
        # Dọn dẹp thư mục tạm thời nếu giải nén thất bại
        rm -rf "$dest_dir"
        return 1
    fi

    # Xóa tệp RPM đã sao chép sau khi giải nén
    rm -f "$dest_dir/$(basename "$rpm_file")"
    echo "Extraction successful."

    # --- 4. Xác nhận và Sao chép Tệp Hệ thống ---
    echo "Ready to copy extracted files from '$dest_dir' to /"
    printf "Proceed with installation (copy to /)? [y/N]: "
    read -r confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborted by user."
        # Dọn dẹp thư mục tạm thời
        rm -rf "$dest_dir"
        return 0
    fi

    echo "Copying files to / (requires sudo)..."

    # Lệnh 'cp -rT' sao chép nội dung của source_dir vào destination_dir
    if sudo cp -rT "$dest_dir" /; then
        echo "Installation complete from $rpm_file"
        # Xóa thư mục tạm thời sau khi cài đặt thành công
        rm -rf "$dest_dir"
        return 0
    else
        echo "Error: Copying failed. Check sudo permissions and target disk status." >&2
        # Giữ lại thư mục đã giải nén để debug nếu quá trình sao chép thất bại
        return 1
    fi
}

# --- Ví dụ cách sử dụng Script ---

# Kiểm tra xem có đối số nào được cung cấp không
if [ -n "$1" ]; then
    install_rpm "$@"
else
    # Nếu không có đối số, chạy hàm với thông báo usage.
    # Hàm sẽ tự xử lý thông báo lỗi.
    install_rpm
fi
