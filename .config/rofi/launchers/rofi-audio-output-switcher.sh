#!/usr/bin/env bash

FONT="JetBrainsMono Nerd Font 12"

# Lấy danh sách sink (thiết bị đầu ra)
mapfile -t sinks < <(pactl list short sinks)

# Lấy thiết bị hiện tại
current_sink=$(pactl get-default-sink)

# Tạo ánh xạ mô tả → tên kỹ thuật
declare -A sink_map
choices=()

for line in "${sinks[@]}"; do
    sink_name=$(echo "$line" | awk '{print $2}')

    # Lấy mô tả thiết bị
    sink_desc=$(pactl list sinks | awk -v name="$sink_name" '
        $0 ~ "Name: "name {found=1}
        found && /Description:/ {print substr($0, index($0,$2)); exit}
    ')

    # Nếu không có mô tả thì dùng tên kỹ thuật
    [[ -z "$sink_desc" ]] && sink_desc="$sink_name"

    # Đánh dấu thiết bị đang dùng
    if [[ "$sink_name" == "$current_sink" ]]; then
        choices+=("* $sink_desc")
    else
        choices+=("  $sink_desc")
    fi

    # Lưu ánh xạ
    sink_map["$sink_desc"]="$sink_name"
done

# Hiển thị menu bằng rofi
selected=$(printf "%s\n" "${choices[@]}" | rofi -i -dmenu -p "Chọn thiết bị đầu ra:" -font "$FONT" -matching fuzzy)

# Nếu người dùng không chọn gì thì thoát
[[ -z "$selected" ]] && exit 0

# Loại bỏ dấu * và khoảng trắng
selected_desc=$(echo "$selected" | sed 's/^[* ]*//')

# Tra tên sink kỹ thuật
selected_sink="${sink_map[$selected_desc]}"

# Nếu không tìm được thiết bị phù hợp → thoát
[[ -z "$selected_sink" ]] && {
    echo "Không tìm thấy thiết bị phù hợp cho \"$selected_desc\""
    exit 1
}

# Đặt thiết bị được chọn làm mặc định
pactl set-default-sink "$selected_sink"

# Di chuyển các stream hiện tại sang sink mới
while read -r input; do
    pactl move-sink-input "$input" "$selected_sink"
done < <(pactl list short sink-inputs | awk '{print $1}')
