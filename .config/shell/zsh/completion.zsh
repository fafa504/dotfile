fpath=("$HOME/.config/completions" $fpath)

autoload -Uz compinit && compinit

zinit cdreplay -q 

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

zstyle ':fzf-tab:complete:mintori:argument-1' fzf-preview "$HOME/.config/shell/lib/helper/preview.sh {}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

