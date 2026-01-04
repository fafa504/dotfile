#!/usr/bin/env bash

__utils_check_deps() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "[Completion Error] '$cmd' is required but not installed." >&2
            return 1
        fi
    done
    return 0
}
