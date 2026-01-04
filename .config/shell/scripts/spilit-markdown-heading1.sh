#!/usr/bin/env bash
set -euo pipefail

# Định nghĩa hàm để tách file Markdown
split_markdown_by_heading1() {
    # Kiểm tra đầu vào
    if [ -z "$1" ]; then
        echo "Usage: split_markdown_by_heading1 <input_markdown_file>"
        echo "Splits a markdown file into separate files based on H1 headings (#), skipping content before the first H1."
        return 1
    fi

    input_file="$1"

    # Kiểm tra sự tồn tại của file
    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' not found."
        return 1
    fi

    echo "Processing file: $input_file"

    # Sử dụng awk để xử lý file
    awk '
    # Khởi tạo cờ cho biết đã tìm thấy H1 đầu tiên hay chưa
    BEGIN { 
        FN = "";
        # FLAG = 0 nghĩa là chưa tìm thấy H1 đầu tiên
        # FLAG = 1 nghĩa là đã tìm thấy H1 đầu tiên và bắt đầu in nội dung
        FIRST_H1_FOUND = 0; 
    }

    # Block xử lý khi tìm thấy một H1 mới
    /^# / {
        # Đặt cờ là 1 vì đã tìm thấy H1
        FIRST_H1_FOUND = 1;

        # 1. Nếu một file đang mở, đóng nó lại.
        if (FN != "") {
            close(FN);
        }

        # 2. Xử lý tiêu đề để tạo tên file
        TITLE = $0;
        sub(/^# /, "", TITLE);
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", TITLE);
        
        # 3. Sanitize tiêu đề cho tên file
        FN = TITLE;
        gsub(/[[:space:]]+/, "_", FN);
        # Loại bỏ ký tự không hợp lệ, giữ lại chữ, số, gạch ngang, gạch dưới.
        gsub(/[^[:alnum:]_-]/, "", FN);
        FN = FN ".md";

        # 4. In dòng H1 hiện tại vào file mới.
        print $0 > FN;
        
        # 5. Bỏ qua dòng này, chuyển sang dòng tiếp theo
        next;
    }
    
    # Block xử lý cho các dòng nội dung
    {
        # Chỉ in dòng nếu:
        # 1. Đã tìm thấy H1 đầu tiên (FIRST_H1_FOUND == 1)
        # 2. Và một tên file hợp lệ đang mở (FN != "")
        if (FIRST_H1_FOUND == 1 && FN != "") {
            # Sử dụng >> để nối nội dung vào file hiện tại
            print $0 >> FN;
        }
    }

    # Block cuối cùng để đảm bảo đóng file đang mở nếu có
    END {
        if (FN != "") {
            close(FN);
        }
    }' "$input_file"

    return 0
}

# Lặp qua tất cả các đối số được truyền (tên file)
for file in "$@"; do
    split_markdown_by_heading1 "$file"
done
