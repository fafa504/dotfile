#!/usr/bin/env bash

mapfile -t sinks < <(pactl list short sinks)
current_sink=$(pactl get-default-sink)

get_desc() {
    pactl list sinks | awk -v name="$1" '
        $0 ~ "Name: "name {found=1}
        found && /Description:/ {print substr($0, index($0,$2)); exit}
    '
}

if [ -z "$1" ]; then
    for line in "${sinks[@]}"; do
        sink_name=$(echo "$line" | awk '{print $2}')
        sink_desc=$(get_desc "$sink_name")
        [[ -z "$sink_desc" ]] && sink_desc="$sink_name"

        if [[ "$sink_name" == "$current_sink" ]]; then
            echo "CURRENT: $sink_desc"
        else
            echo "$sink_desc"
        fi
    done
    exit 0
fi

SELECTED_INPUT="$1"
CLEAN_DESC=$(echo "$SELECTED_INPUT" | sed 's/^CURRENT: //')

SELECTED_SINK_NAME=""
for line in "${sinks[@]}"; do
    s_name=$(echo "$line" | awk '{print $2}')
    s_desc=$(get_desc "$s_name")
    [[ -z "$s_desc" ]] && s_desc="$s_name"

    if [[ "$s_desc" == "$CLEAN_DESC" ]]; then
        SELECTED_SINK_NAME="$s_name"
        break
    fi
done

if [[ -n "$SELECTED_SINK_NAME" ]]; then
    pactl set-default-sink "$SELECTED_SINK_NAME"

    while read -r stream_id; do
        pactl move-sink-input "$stream_id" "$SELECTED_SINK_NAME"
    done < <(pactl list short sink-inputs | awk '{print $1}')

    # echo "Switched to $SELECTED_SINK_NAME"
fi
