#!/usr/bin/env bash

# --- Dependency Checks ---
# Exit if 'curl' or 'jq' is not found.
if ! command -v curl &>/dev/null; then
    echo -e "\033[0;31mError:\033[0m 'curl' is not installed. Please install it to use this script." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo -e "\033[0;31mError:\033[0m 'jq' is not installed. Please install it to use this script." >&2
    exit 1
fi
# --- End Dependency Checks ---

# Define the main 'ai' function
function ai() {
    # --- Color and API Variables ---
    local R='\033[0;31m' G='\033[0;32m' Y='\033[0;33m' B='\033[0;34m' C='\033[0;36m' M='\033[0;35m' N='\033[0m'
    local CACHE_FILE="${HOME}/.gcmd_router_cache"
    local MODEL="mistralai/mistral-small-3.2-24b-instruct:free"
    local API_URL="https://openrouter.ai/api/v1/chat/completions"

    # --- Pre-flight Checks ---
    if [[ -z "$OPENROUTER_API_KEYS" ]]; then
        echo -e "${R}Error:${N} OPENROUTER_API_KEYS environment variable is not set." >&2
        echo -e "Please set it first, e.g.: ${Y}export OPENROUTER_API_KEYS=\"your_key_here\"${N}" >&2
        return 1
    fi

    # Check for empty input
    if [[ -z "$*" ]]; then
        echo -e "${R}Error:${N} No prompt provided." >&2
        echo -e "Usage: ${Y}./cli.sh <your question here>${N}" >&2
        return 1
    fi

    # --- Local Variables ---
    local DESC="$*" RAW_JSON CMD KEY_LIST
    local CMD_FOUND=false
    local START_TIME END_TIME ELAPSED_TIME

    echo -e "${B}-->${N} $DESC"

    # 1. CHECK LOCAL CACHE (FASTEST)
    if [[ -f "$CACHE_FILE" ]]; then
        CMD=$(grep -m 1 "^${DESC}::" "$CACHE_FILE" | cut -d: -f3)
        if [[ -n "$CMD" ]]; then
            CMD_FOUND=true
            echo -e "${B}Command found in local cache (Instant)${N}"
        fi
    fi

    # 2. CALL OPENROUTER API WITH KEY ROTATION
    if ! $CMD_FOUND; then
        echo -e "${B}Generating command with OpenRouter AI...${N}"

        KEY_LIST=$(echo $OPENROUTER_API_KEYS | tr "," " ") # Convert comma-separated string to list
        local ALL_KEYS_FAILED=true
        local KERNEL_VERSION="$(uname -r)"

        # Lấy thông tin về Shell (Bash) và phiên bản
        local ZSH_VERSION_INFO="$ZSH_VERSION"

        # --- Kiểm tra giao thức hiển thị (Display Protocol) ---
        local DISPLAY_PROTOCOL="Unknown"

        # 1. Kiểm tra biến môi trường $WAYLAND_DISPLAY
        if [ -n "$WAYLAND_DISPLAY" ]; then
            DISPLAY_PROTOCOL="Wayland"
        # 2. Kiểm tra biến môi trường $DISPLAY (đặc trưng của X11/Xorg)
        elif [ -n "$DISPLAY" ]; then
            DISPLAY_PROTOCOL="X11 (Xorg)"
        fi
        # --- Kết thúc kiểm tra ---

        for KEY in $KEY_LIST; do
            # echo -e "${M}Attempting with key ending in: ${KEY: -4}${N}"

            local PROMPT_TEXT="You are a Bash terminal (v$ZSH_VERSION_INFO) running on Kernel v$KERNEL_VERSION. The current graphical display server is $DISPLAY_PROTOCOL. Write exactly one valid Bash command that performs the following task: '$DESC'. Do not explain, do not use quotes, output only the command."

            # Build JSON payload
            local PAYLOAD=$(
                cat <<EOF
{
  "model": "$MODEL",
  "messages": [
    {"role": "system", "content": "You are a bash shell assistant. Respond only with a valid bash command, without explanation, quotes, or any extra text."},
    {"role": "user", "content": "$PROMPT_TEXT"}
  ],
  "max_tokens": 50,
  "temperature": 0.0
}
EOF
            )
            START_TIME=$(date +%s.%N)

            # Make the curl call
            RAW_JSON=$(curl -s -X POST "$API_URL" \
                -H "Authorization: Bearer $KEY" \
                -H "Content-Type: application/json" \
                -d "$PAYLOAD")

            END_TIME=$(date +%s.%N)
            ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)

            # --- CHECK FOR RATE LIMITS AND OTHER ERRORS ---

            # Check if the JSON response contains an "error" object
            if echo "$RAW_JSON" | grep -q '"error":'; then
                local ERROR_MESSAGE=$(echo "$RAW_JSON" | jq -r '.error.message // .error.type // "Unknown API Error"')

                # Switch key if it's a rate limit, quota, or auth error
                if echo "$ERROR_MESSAGE" | grep -qE "(Rate limit|limit exceeded|quota|Unauthorized|invalid_key)"; then
                    echo -e "${R}Key failed: $ERROR_MESSAGE. Switching key...${N}"
                    continue # Move to the next key in the loop
                else
                    # A different, more serious error occurred (e.g., model config)
                    echo -e "${R}Critical API Error: $ERROR_MESSAGE. Aborting key rotation.${N}"
                    break # Stop the loop and fail
                fi
            fi

            # If no error, parse the command
            CMD=$(echo "$RAW_JSON" | jq -r '.choices[0].message.content' | tr -d '\r')

            # Clean up leading/trailing whitespace
            CMD=$(echo "$CMD" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

            # Check if the command is valid (not an error message or "null")
            if [[ -n "$CMD" && ! "$CMD" =~ ^(Error|None|I cannot|I can’t|Lỗi|Sorry) && "$CMD" != "null" ]]; then
                ALL_KEYS_FAILED=false
                # echo -e "${G}Successfully generated command.${N}"
                # echo -e "${C}AI Response Time: ${ELAPSED_TIME}s${N}"
                # Save to cache
                echo "${DESC}::${CMD}" >>"$CACHE_FILE"
                break # Success, exit the key rotation loop
            else
                echo -e "${R}Key returned invalid command ('$CMD'). Switching key...${N}"
                # Loop will continue to the next key
            fi

        done

        if $ALL_KEYS_FAILED; then
            echo -e "${R}All API keys failed or returned an error command. Aborting.${N}" >&2
            return 1
        fi
    fi

    # 3. DISPLAY AND RUN COMMAND
    echo -e "${Y}$CMD${N}"
    wl-copy "$CMD"

    # Prompt the user to run the command. This works in both Bash and Zsh.
    printf "Run this command? [Y/n]: "
    read ans
    echo "" # Add a newline

    # Default to "Yes" if 'ans' is empty (Enter key) or "Y" or "y"
    [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]] || {
        echo "Cancelled."
        return 0
    }

    eval "$CMD"
    local ec=$?
    [ $ec -eq 0 ] && echo -e "${G}Done.${N}" || echo -e "${R}Exited with code $ec.${N}"
}

# --- Main Execution ---
# Pass all script arguments (e.g., "how to create file")
# to the 'ai' function.
ai "$@"
