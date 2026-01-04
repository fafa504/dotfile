#!/bin/bash

PORT=6419

# 1. Tự động giải phóng cổng nếu có phiên cũ đang chạy ngầm
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null; then
    echo "♻️  Đang làm mới phiên preview cũ..."
    fuser -k $PORT/tcp >/dev/null 2>&1
fi

# 2. Xử lý clipboard
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    PASTE_CMD="wl-paste"
else
    PASTE_CMD="xclip -selection clipboard -o"
fi

# 3. Tạo tệp tạm
TMP_FILE=$(mktemp /tmp/md_clip_XXXX.md)
$PASTE_CMD >"$TMP_FILE"

# 4. Kiểm tra file
if [ ! -s "$TMP_FILE" ]; then
    echo "❌ Lỗi: Clipboard trống!"
    rm "$TMP_FILE"
    exit 1
fi

echo "🚀 Đang khởi chạy preview tại cổng: $PORT"

# 5. Dọn dẹp khi thoát
trap 'rm -f "$TMP_FILE"; echo "✅ Đã dọn dẹp."; exit' INT TERM EXIT

# 6. Chạy go-grip với cổng đã chọn
# Thêm tham số --port để tránh xung đột
go-grip --port "$PORT" --theme light "$TMP_FILE"
