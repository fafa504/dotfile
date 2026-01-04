#!/usr/bin/env bash

# --- CẤU HÌNH ---

# Các thư mục cần tìm kiếm
SEARCH_DIRS=("$HOME")

# Cấu hình Rofi
FONT="JetBrainsMono Nerd Font 11"
ROFI_PROMPT=" Tìm file"

# Biểu thức regex để lọc các loại file mong muốn
EXT_REGEX='.*\.(pdf|md|txt|sh|jpg|png|py|mp3|mp4|mkv|tsx|jsx|js|ts|cpp|c|h|html|css|json|yaml|toml|rs|java|php|sql|env|doc|docx|xls|xlsx|ppt|pptx|tex|ipynb|zip|gz|iso)$'

# Các thư mục/file cần loại trừ khỏi kết quả tìm kiếm
EXCLUDED_DIRS=(
    # 🔁 Runtime, cache, và tạm thời
    .cache .local .local/share/Trash /var /tmp /run
    __pycache__ .mypy_cache .pytest_cache .ipynb_checkpoints .scannerwork .history
    .DS_Store .Trash .thumbnails .log .logs logs .coverage coverage

    # 🧱 Build artifacts
    build dist out target bin obj
    .gradle .next .vite .parcel-cache .svelte-kit .angular .turbo .vercel .expo .output

    # 💻 IDE/editor config
    .idea .vscode .eclipse .settings .classpath .project .metadata
    .devcontainer .nvim .vimspector .nvim-data .emacs.d .doom.d

    # ⚙️ Toolchains & SDKs
    .cargo .rustup .venv .venvs venv venvs env envs .pyenv __pypackages__
    .dotnet .sdk .java .jdks go/pkg .go goclone/pkg .npm .nvm .nodebrew .bun .yarn .pnpm-store .deno
    .rbenv .gem .bundle .composer .dart .pub-cache .zig

    # 🧪 Test/CI/CD
    .coverage .nyc_output junit test-results test-outputs .tox .test-cache .pytest_cache

    # 📦 Package managers, caches
    node_modules .pip .pypoetry .cargo .rubygems .maven .ivy2 .sbt .nuget .bloop .jbang .config/composer .config/Code .config/JetBrains .vscode-oss .platformio .config/Typora .electron-gyp .gemini .arduinoIDE .arduino15 .dart-tool

    # 🌐 Browsers, apps
    .mozilla .firefox .chromium .config/google-chrome .thunderbird .anydesk .teamviewer
    .steam .wine .flatpak .snap .var .android .vscode-server .jupyter BraveSoftware

    # 🧩 Shell, terminal
    .bash_history .bash_sessions .zsh_history .oh-my-zsh .tmux .tmuxinator .screen .ssh
    .gnupg .gnome .cursor .fonts .icons .themes

    # 🔐 Secrets
    .env .secrets .credentials .certs .keys .ssh .gpg .aws .azure .kube .terraform .ansible

    # 📁 Media/temp
    __MACOSX .photoslibrary Thumbs.db .fseventsd .Spotlight-V100

    # 🗃 App-specific
    .obsidian .code .weechat .ncmpcpp .mpd .mutt .newsboat .config/rclone

    /home/mintri/Onedrive
)

# --- KIỂM TRA DEPENDENCIES ---

for cmd in fd rofi xdg-open; do
    if ! command -v "$cmd" &>/dev/null; then
        rofi -e "Lệnh '$cmd' không tồn tại. Vui lòng cài đặt để sử dụng."
        exit 1
    fi
done

# --- HÀM LẤY ICON TỪ TÊN FILE (DÙNG NERD FONT) ---

get_icon() {
    local lower_filename="${1,,}"
    case "$lower_filename" in
    *.pdf) echo "" ;;
    *.md) echo "" ;;
    *.txt | *.log) echo "" ;;
    *.sh | *.bash) echo "" ;;
    *.jpg | *.png | *.gif | *.jpeg | *.webp) echo "" ;;
    *.zip | *.tar | *.gz | *.rar | *.7z) echo "" ;;
    *.mp4 | *.mkv | *.mov | *.avi) echo "" ;;
    *.mp3 | *.wav | *.flac | *.ogg) echo "" ;;
    *.py) echo "" ;;
    *.js | *.jsx) echo "" ;;
    *.ts | *.tsx) echo "" ;;
    *.cpp | *.c | *.h) echo "" ;;
    *.html) echo "" ;;
    *.css) echo "" ;;
    *.json) echo "" ;;
    *.yaml | *.yml) echo "" ;;
    *.toml) echo "" ;;
    *.rs) echo "" ;;
    *.java) echo "" ;;
    *.php) echo "" ;;
    *.sql) echo "" ;;
    *.env) echo "" ;;
    *.doc | *.docx) echo "" ;;
    *.xls | *.xlsx) echo "" ;;
    *.ppt | *.pptx) echo "" ;;
    *.tex) echo "ﭨ" ;;
    *.iso) echo "" ;;
    *) echo "" ;; # Mặc định
    esac
}

# --- HÀM TẠO DANH SÁCH FILE VÀ TRUYỀN VÀO ROFI ---

generate_and_show_rofi() {
    local EXCLUDE_ARGS=()
    for dir in "${EXCLUDED_DIRS[@]}"; do
        EXCLUDE_ARGS+=(--exclude "$dir")
    done

    fd --hidden --no-ignore -I -t f "${EXCLUDE_ARGS[@]}" --regex "$EXT_REGEX" "${SEARCH_DIRS[@]}" |
        while IFS= read -r file; do
            icon=$(get_icon "$file")
            short_path="${file/#$HOME/~}"
            echo "$icon  $short_path :: $file"
        done
}

# --- GỌI ROFI VÀ XỬ LÝ LỰA CHỌN ---

SELECTED_FILE=$(
    generate_and_show_rofi | rofi -dmenu -i \
        -p "$ROFI_PROMPT" \
        -font "$FONT" \
        -format 'p' \
        -matching fuzzy
)

# --- MỞ FILE ---

# Tách đường dẫn thật
FILE_REAL=$(echo "$SELECTED_FILE" | awk -F' :: ' '{print $2}')

# Kiểm tra và mở file
if [[ -f "$FILE_REAL" ]]; then
    xdg-open "$FILE_REAL" >/dev/null 2>&1 &
    disown
fi
