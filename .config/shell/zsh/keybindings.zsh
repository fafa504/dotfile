# Vi mode bindings
bindkey -v

# History search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Edit command line in editor
bindkey -M vicmd v edit-command-line

# Kill region (Alt+w style)
bindkey '^[w' kill-region
