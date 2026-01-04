#!/bin/bash
# ==========================================================
# Arch Linux Cache Cleaner (Non-interactive)
# ==========================================================

set -e

echo "=== Clearing Cache in Arch Linux ==="

# 1. Clean pacman cache (keeps last 3 versions)
echo "[1/4] Cleaning pacman cache..."
sudo paccache -r

# Uncomment the next line to delete all cached packages
# sudo paccache -rk0

# 2. Clear old package files
echo "[2/4] Cleaning /var/cache/pacman/pkg/..."
sudo rm -rf /var/cache/pacman/pkg/*

# 3. Clear old journal logs (keep 3 days)
echo "[3/4] Cleaning systemd journal logs..."
sudo journalctl --vacuum-time=3d

# 4. Clear user caches
echo "[4/4] Cleaning user cache directories..."
rm -rf ~/.cache/*

echo "Cache cleanup completed successfully."
