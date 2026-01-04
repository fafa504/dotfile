#!/usr/bin/env bash
# Hàm 'gg' (Google Search)
# Sử dụng: gg <cụm từ tìm kiếm>
gg() {
    # 1. Ghép tất cả các đối số thành một chuỗi duy nhất,
    #    ngăn cách bằng dấu '+' để chuẩn bị cho URL.
    local query_string
    query_string=$(echo "$@" | tr ' ' '+')

    # 2. Xây dựng URL Google Search hoàn chỉnh
    local search_url="https://www.google.com/search?q=${query_string}"

    # 3. Mở URL trong trình duyệt mặc định.
    #    'xdg-open' là lệnh tiêu chuẩn và hoạt động trên hầu hết các bản phân phối Linux.
    #    Nếu bạn muốn chỉ định trình duyệt, hãy thay thế 'xdg-open' bằng 'firefox' hoặc 'google-chrome'.
    xdg-open "$search_url" &>/dev/null &

    echo "Đang tìm kiếm trên Google: '$@'"
}
