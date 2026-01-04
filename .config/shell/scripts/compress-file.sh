#!/usr/bin/env bash
set -euo pipefail

# Usage: ./archive.sh output.ext file_or_dir [...]

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <output_filename> <files_or_folders...>" >&2
    exit 1
fi

output="$1"
shift

# Detect CPU cores
CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"

# Helper: check if command exists
has() {
    command -v "$1" >/dev/null 2>&1
}

case "$output" in
*.zip)
    # zip is single-threaded, but very portable
    zip -r -9 "$output" "$@"
    ;;

*.tar.gz | *.tgz)
    if has pigz; then
        tar -cf "$output" \
            --use-compress-program="pigz -9 -p $CORES" \
            "$@"
    else
        tar -czf "$output" "$@"
    fi
    ;;

*.tar.bz2 | *.tbz2)
    if has pbzip2; then
        tar -cf "$output" \
            --use-compress-program="pbzip2 -9 -p $CORES" \
            "$@"
    else
        tar -cjf "$output" "$@"
    fi
    ;;

*.tar.xz | *.txz)
    if has pxz; then
        tar -cf "$output" \
            --use-compress-program="pxz -9 -T $CORES" \
            "$@"
    else
        tar -cJf "$output" "$@"
    fi
    ;;

*.tar.zst | *.tzst)
    if has zstd; then
        tar -cf "$output" \
            --use-compress-program="zstd -19 -T$CORES" \
            "$@"
    else
        echo "Error: zstd not installed" >&2
        exit 1
    fi
    ;;

*.tar)
    tar -cf "$output" "$@"
    ;;

*)
    echo "Error: Unsupported extension." >&2
    echo "Supported:" >&2
    echo "  .zip" >&2
    echo "  .tar" >&2
    echo "  .tar.gz  (.tgz)" >&2
    echo "  .tar.bz2 (.tbz2)" >&2
    echo "  .tar.xz  (.txz)" >&2
    echo "  .tar.zst (.tzst)" >&2
    exit 1
    ;;
esac
