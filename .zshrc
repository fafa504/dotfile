if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

safe_source() {
    local file_path="$1"
    [[ -r "$file_path" ]] && source "$file_path"
}

SHELL_CONFIG_ROOT="$HOME/.config/shell"
ZSH_CONFIG_DIR="$SHELL_CONFIG_ROOT/zsh"

typeset -a config_modules

config_modules=(
    plugins.zsh
    api-key.zsh
    environment.zsh
    aliases.zsh
    
    settings.zsh
    not-found.zsh
    keybindings.zsh
    completion.zsh
    functions.zsh
    fzf-completion.zsh
    external.zsh
)

for module in $config_modules; do
    safe_source "$ZSH_CONFIG_DIR/$module"
done

unset -f safe_source

[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"


# IntelliShell
export INTELLI_HOME="/home/mintori/.local/share/intelli-shell"
# export INTELLI_SEARCH_HOTKEY='^@'
# export INTELLI_VARIABLE_HOTKEY='^l'
# export INTELLI_BOOKMARK_HOTKEY='^b'
# export INTELLI_FIX_HOTKEY='^x'
# export INTELLI_SKIP_ESC_BIND=0
# alias is="intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
eval "$(intelli-shell init zsh)"

