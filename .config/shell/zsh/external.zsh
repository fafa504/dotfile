# Input method
# ibus engine BambooUs

# --- TOOLS INITIALIZATION ---
# Check if tools exist before initializing to avoid errors

if type navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
fi

if type zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if type mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

if type fixit >/dev/null 2>&1; then
    eval "$(fixit init zsh)"
fi

if type rc >/dev/null 2>&1; then
    eval "$(rc completion)"
fi

if type mcfly >/dev/null 2>&1; then
    eval "$(mcfly init zsh)"
fi
