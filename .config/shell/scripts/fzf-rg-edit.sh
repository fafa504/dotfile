#!/bin/bash

# Script created on Wed  3 Dec 01:06:44 +07 2025

fzf-rg-edit() {
    local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"

    # 1. Chạy fzf và lưu kết quả thô vào biến 'result'
    local result
    result=$(
        FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INITIAL_QUERY")" \
            fzf --ansi \
            --disabled --query "$INITIAL_QUERY" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
    )

    # 2. Xử lý kết quả (Logic chuẩn Bash)
    if [[ -n "$result" ]]; then
        # Dùng IFS để tách chuỗi dựa trên dấu hai chấm (:)
        IFS=':' read -r -a selected <<<"$result"

        # Bash array bắt đầu từ 0 (khác Zsh bắt đầu từ 1)
        # selected[0] = tên file
        # selected[1] = số dòng

        # Kiểm tra biến EDITOR, nếu chưa set thì dùng vim
        ${EDITOR:-vim} "${selected[0]}" "+${selected[1]}"
    fi
}

# Truyền tham số từ dòng lệnh vào hàm
fzf-rg-edit "$@"
