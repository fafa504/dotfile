#!/usr/bin/env bash

export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}
export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

FONT="JetBrainsMono Nerd Font 12"

OPTIONS="󰍹 Ibus daemon
󰤨 Wi-Fi
󰈸 Config Editor
󰈙 Sync Obsidian
󰈙 Sync Config
󰈙 Sync Firefox
󰈙 University
 Prompt
 Preview Markdown
󰈙 Log
󰊢 Git Projects
 Files Finder
󰝚 Music
󰐊 Open with Mpv
󰕾 Audio Switcher
 Systemctl
 Youtube Download
󰍹 Yay install
󰍹 Yay install (noconfirm)
󰍹 Yay uninstall
 Edit Clipboard
󰠟 2025
 Bluetooth Menu
󰍹 Speed Test
󰖳 Boot to Windows
󰍹 Keyboard Enable
 Power Menu"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "⚙️ Launcher" -font "$FONT" -matching fuzzy)

case "$CHOICE" in
    "󰍹 Ibus daemon") "$HOME/.config/rofi/launchers/rofi-ibus-daemon.sh" ;;
    "󰤨 Wi-Fi") "$HOME/.config/rofi/launchers/rofi-wifi-menu.sh" ;;
    "󰝚 Music") mpv --force-window --shuffle ~/Music & ;;
    "󰈙 University") "$HOME/.config/rofi/launchers/rofi-university.sh" ;;
    " Bluetooth Menu") "$HOME/.config/rofi/launchers/rofi-bluetooth.sh" ;;
    "󰈸 Config Editor") "$HOME/.config/rofi/launchers/rofi-config-menu.sh" ;;
    "󰈙 Sync Obsidian") "$HOME/.config/rofi/launchers/rofi-sync-obsidian.sh" ;;
    "󰈙 Sync Config") "$HOME/.config/rofi/launchers/rofi-sync-config.sh" ;;
    "󰈙 Sync Firefox") "$HOME/.config/rofi/launchers/rofi-sync-firefox.sh" ;;
    "󰈙 Log") "$HOME/.config/rofi/launchers/rofi-log-selecter.sh" ;;
    "󰍹 Yay install") alacritty -e zsh -c '~/.config/rofi/launchers/install-yay.sh' ;;
    "󰍹 Yay install (noconfirm)") alacritty -e zsh -c '~/.config/rofi/launchers/install-yay.sh --noconfirm' ;;
    "󰍹 Yay uninstall") alacritty -e zsh -c '~/.config/rofi/launchers/uninstall-yay.sh' ;;

    " Systemctl") kitty -e zsh -c "systemctl-tui" ;;
    "󰠟 2025")
        xdg-open "/home/mintori/Documents/[2] Obsidian/05_Personal/03-Finance/2025/Month-12.xlsx"
        ;;
    " Youtube Download")
        kitty -- zsh -c "yt-dlp \"$(wl-paste)\""
        ;;
    " Prompt")
        "$HOME/.config/rofi/launchers/rofi-prompt-ai.sh"
        ;;
    # "▶︎ Video") kitty --config "$HOME/.config/kitty/kitty.conf" zsh -c 'cd "$HOME/Downloads/Youtube" && yazi && exit' ;;
    "󰕾 Audio Switcher") "$HOME/.config/rofi/launchers/rofi-audio-output-switcher.sh" ;;
    "󰚩 ChatGPT (temp)") firefox --new-tab "https://chatgpt.com/?temporary-chat=true" & ;;
    "󰚩 ChatGPT") firefox --new-tab 'https://chatgpt.com' & ;;
    "󰋒 Google Calendar") firefox --new-tab 'https://calendar.google.com' & ;;
    "󰊢 Git Projects") "$HOME/.config/rofi/launchers/rofi-search-git-projects.sh" ;;
    " Files Finder") "$HOME/.config/rofi/launchers/rofi-finder.sh" ;;
    "󰍹 Speed Test")
        kitty -e zsh -c "speedtest-cli; read -n 1 -s -r -p 'Press any key to exit...'; echo"
        ;;
    " Preview Markdown")
        $HOME/.config/rofi/launchers/utils/markdown-preview-clipboard.sh
        ;;

    "󰍹 Keyboard Enable")
        "$HOME/.config/rofi/launchers/rofi-keyboard-laptop-toggle.sh"
        ;;

    " Emoji Finder") ;;
    "󰐊 Open with Mpv")
        url=$(wl-paste)
        [ -n "$url" ] && mpv "$url" &
        ;;
    "󰖳 Boot to Windows")
        "$HOME/.config/rofi/launchers/rofi-boot-to-windows.sh"
        ;;
    " System")
        sh "$HOME/.config/rofi/launchers/rofi-system.sh"
        ;;
    " Power Menu") "$HOME/.config/rofi/launchers/rofi-power-menu.sh" ;;
    " Edit Clipboard") kitty -e nvim -c 'enew' -c 'set noro' \
        -c 'call setline(1, split(system("wl-paste"), "\n"))' \
        -c 'set nomodified' -c 'set filetype=markdown' \
        -c 'set buftype=acwrite' \
        -c 'au BufWriteCmd <buffer> silent exe "!wl-copy < %" | silent! wq' ;;
    *) echo "No valid option selected." ;;
esac
