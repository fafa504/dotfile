#!/usr/bin/env bash
set -euo pipefail

pkexec sh -c '
    grub-reboot "Windows Boot Manager (on /dev/nvme0n1p1)"
    reboot
'
