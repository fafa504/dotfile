#!/usr/bin/env zsh

# ----- Colors -----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [[ $# -lt 2 ]]; then
    echo -e "${YELLOW}Usage:${NC} cv <input_file> <output_file>"
    exit 1
fi

input="$1"
output="$2"

# ----- Extension extraction -----
in_ext="${input##*.}"
out_ext="${output##*.}"

# ----- Check if input exists -----
if [[ ! -f "$input" ]]; then
    echo -e "${RED}Error:${NC} Input file '${input}' not found."
    exit 1
fi

echo -e "${BLUE}Converting${NC} '$input' ($in_ext) → '$output' ($out_ext)"

show_progress() {
    local duration time cur percent

    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input" 2>/dev/null)
    duration=${duration%.*}

    if [[ -z "$duration" || "$duration" -eq 0 ]]; then
        ffmpeg "$@" >/dev/null 2>&1
        return
    fi

    ffmpeg "$@" 2>&1 | while IFS= read -r line; do
        if [[ $line == *"time="* ]]; then
            time=$(echo "$line" | sed -n 's/.*time=\([^ ]*\).*/\1/p')
            if [[ -n "$time" && -n "$duration" ]]; then
                IFS=':' read -r h m s <<< "$time"
                cur=$(echo "$h*3600 + $m*60 + $s" | bc)
                percent=$((cur * 100 / duration))
                printf "\r${YELLOW}Progress:${NC} %3d%%" "$percent"
            fi
        fi
    done
    echo
}

case "$in_ext:$out_ext" in
    # --- Subtitle conversions (ffmpeg) ---
    srt:vtt|vtt:srt|ass:srt|ssa:srt|srt:ass|ssa:ass|ass:vtt)
        echo -e "${BLUE}Converting subtitle format...${NC}"
        ffmpeg -y -i "$input" "$output" >/dev/null 2>&1
        ;;

    # --- Documents (pandoc) ---
    md:pdf|txt:pdf)
        echo -e "${BLUE}Converting to PDF... (pandoc/latex)${NC}"
        # Sử dụng pandoc, yêu cầu cài đặt LaTeX
        pandoc "$input" -o "$output" --pdf-engine=xelatex --pdf-engine-opt='-V mainfont="SF Pro Display"'
        ;;

    # --- Epub
    md:epub)
        echo -e "${BLUE}Converting to EPUB... (pandoc/latex)${NC}"
        pandoc "$input" -o "$output"
        ;;

    # --- Documents (Rust: comrak) ---
    md:html|txt:html)
        echo -e "${BLUE}Converting to HTML... (comrak)${NC}"
        comrak "$input" -o "$output"
        ;;

    # --- Documents (Rust: html2md) ---
    html:md)
        echo -e "${BLUE}Converting HTML to Markdown... (html2md)${NC}"
        html2md < "$input" > "$output"
        ;;

    # --- Documents (wkhtmltopdf) ---
    html:pdf)
        echo -e "${BLUE}Converting HTML to PDF... (wkhtmltopdf)${NC}"
        wkhtmltopdf "$input" "$output"
        ;;

    # --- Documents (Pandoc - Chỉ cho các trường hợp phức tạp) ---
    md:docx|docx:md|rtf:md)
        echo -e "${BLUE}Converting document... (pandoc)${NC}"
        pandoc "$input" -f "$in_ext" -t "$out_ext" -o "$output"
        ;;

    # --- Spreadsheet/Data (xan) ---
    xlsx:csv|json:csv|xml:csv)
        echo -e "${BLUE}Converting to CSV... (xan)${NC}"
        xan from "$input" -o "$output"
        ;;
    csv:xlsx|csv:json|csv:xml)
        echo -e "${BLUE}Converting from CSV... (xan)${NC}"
        xan input "$input" | xan to "$out_ext" -o "$output"
        ;;

    # --- Data Formats (yq) ---
    json:yaml|yaml:json|json:toml|toml:json|xml:json|json:xml|yaml:toml)
        echo -e "${BLUE}Converting data format... (yq)${NC}"
        # yq tự động phát hiện định dạng input
        yq -o "$out_ext" "$input" > "$output"
        ;;

    # --- Images (ImageMagick) ---
    avif:png|jpg:png|png:jpg|jpeg:webp|png:webp|webp:png|gif:png|tiff:jpg)
        echo -e "${BLUE}Converting image... (convert)${NC}"
        convert "$input" "$output"
        ;;

    # Mở rộng: HEIC, SVG, PDF (lấy trang đầu), ICO
    heic:jpg|heic:png||svg:png|svg:jpg|png:ico|jpg:ico)
        echo -e "${BLUE}Converting image... (convert)${NC}"
        convert "$input" "$output"
        ;;
    png:svg|jpg:svg)
        echo -e "${BLUE}Converting image to svg... (convert)${NC}"
        inkscape "$input" --export-type=svg --export-filename="$output"
        ;;
    pdf:png) 
        # Convert tất cả các trang PDF sang PNG chất lượng cao
        output_dir="${output%.*}"
        output_ext="png"

        echo -e "${BLUE}Đang convert PDF sang PNG (tất cả trang) vào thư mục '$output_dir'... (convert)${NC}"
        mkdir -p "$output_dir"
        
        # Chất lượng PNG chủ yếu phụ thuộc vào -density (độ phân giải).
        # -density 400: Độ phân giải cao (có thể tăng lên 500, 600 nếu muốn nét hơn nữa)
        # -quality 92: Mức nén tốt cho PNG (vì PNG là lossless, 
        #              quality càng cao -> nén càng nhiều -> file càng nhỏ, không ảnh hưởng chất lượng ảnh)
        convert -density 400 "${input}" -quality 92 "$output_dir/page-%d.$output_ext"
        ;;

    pdf:jpg) 
        # Convert tất cả các trang PDF sang JPG chất lượng cao
        output_dir="${output%.*}"
        output_ext="jpg"

        echo -e "${BLUE}Đang convert PDF sang JPG (tất cả trang) vào thư mục '$output_dir'... (convert)${NC}"
        mkdir -p "$output_dir"
        
        # -density 400: Độ phân giải cao
        # -quality 100: Chất lượng JPG tối đa (ít nén nhất, giữ chi tiết tốt nhất)
        # -flatten: Rất quan trọng! Gộp các lớp (layer) của PDF và
        #           thêm nền trắng, tránh bị lỗi nền đen khi file PDF có transparency.
        convert -density 400 "${input}" -quality 100 -flatten "$output_dir/page-%d.$output_ext"
        ;;

    # --- Audio (ffmpeg) ---
    mp3:wav|wav:mp3|flac:mp3|ogg:mp3|m4a:mp3|opus:mp3|m4a:wav)
        echo -e "${BLUE}Encoding audio...${NC}"
        show_progress -y -i "$input" "$output"
        ;;

    # Mở rộng: Trích xuất audio
    mp4:mp3|webm:mp3|mkv:mp3|mov:mp3)
        echo -e "${BLUE}Extracting audio to MP3...${NC}"
        # -vn (no video), -b:a (audio bitrate)
        show_progress -y -i "$input" -vn -b:a 192k "$output"
        ;;
    mp4:aac|mkv:aac) # Trích xuất, không encode lại nếu có thể
        echo -e "${BLUE}Extracting AAC audio stream...${NC}"
        show_progress -y -i "$input" -vn -c:a copy "$output"
        ;;
    
    # --- Video (ffmpeg) ---
    mp4:avi|avi:mp4|mkv:mp4|mov:mp4|mp4:webm|webm:mp4)
        echo -e "${BLUE}Encoding video...${NC}"
        show_progress -y -i "$input" -c:v libx264 -c:a aac "$output"
        ;;

    # Mở rộng: Video <-> GIF
    gif:mp4)
        echo -e "${BLUE}Converting GIF to MP4...${NC}"
        # Thêm bộ lọc pix_fmt=yuv420p để tương thích rộng
        show_progress -y -i "$input" -movflags +faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$output"
        ;;
    mp4:gif|webm:gif|mov:gif)
        echo -e "${BLUE}Converting video to GIF... (Complex filter)${NC}"
        # Lệnh này tạo GIF chất lượng cao
        ffmpeg -y -i "$input" -vf "fps=10,scale=500:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$output" >/dev/null 2>&1
        ;;

    # --- Office (LibreOffice) ---
    docx:pdf|pptx:pdf|xlsx:pdf|odt:pdf|rtf:pdf)
        echo -e "${BLUE}Converting Office to PDF... (soffice)${NC}"
        soffice --headless --convert-to pdf "$input" --outdir "$(dirname "$output")"
        mv "$(dirname "$input")/$(basename "${input%.*}.pdf")" "$output"
        ;;

    # --- Chuyển đổi giữa các định dạng Office ---
    docx:odt|odt:docx|pptx:odp|odp:pptx|xlsx:ods|ods:xlsx)
        echo -e "${BLUE}Converting Office format... (soffice)${NC}"
        soffice --headless --convert-to "$out_ext" "$input" --outdir "$(dirname "$output")"
        # Đổi tên file output
        mv "$(dirname "$input")/$(basename "${input%.*}.$out_ext")" "$output"
        ;;

    # --- Ebooks (Calibre) [MỚI] ---
    epub:mobi|mobi:epub|azw3:epub|epub:azw3|pdf:epub|html:epub)
        echo -e "${BLUE}Converting ebook... (ebook-convert)${NC}"
        ebook-convert "$input" "$output"
        ;;

    # --- Unsupported ---
    *)
        echo -e "${RED}Unsupported conversion:${NC} ${in_ext} → ${out_ext}"
        echo -e "${YELLOW}Supported types (partial list):${NC}"
        echo "  Subtitles: srt↔vtt/ass/ssa (ffmpeg)"
        echo "  Documents: md↔pdf/html/docx, html↔md (pandoc)"
        echo "  Data: xlsx/json/xml↔csv (xan), json↔yaml↔toml (yq)"
        echo "  Images: jpg↔png/webp, heic→jpg, svg→png, pdf→png (convert)"
        echo "  Audio: mp3↔wav/flac/m4a, mp4→mp3 (ffmpeg)"
        echo "  Video: mp4↔avi/mkv/webm, mp4↔gif (ffmpeg)"
        echo "  Office: (docx/pptx/xlsx)→pdf, docx↔odt (soffice)"
        echo "  Ebooks: epub↔mobi, pdf→epub (ebook-convert)"
        exit 1
        ;;
esac

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}Conversion successful:${NC} $output"
else
    echo -e "\n${RED}Conversion failed.${NC}"
    exit 1
fi

