#!/bin/bash

# Kiểm tra ibus-daemon có chạy hay không
if pgrep -x "ibus-daemon" >/dev/null; then
    echo "ibus đang chạy → restart"
    ibus restart
else
    echo "ibus chưa chạy → start"
    ibus-daemon -drx &
    sleep 1
    ibus engine BambooUs
fi
