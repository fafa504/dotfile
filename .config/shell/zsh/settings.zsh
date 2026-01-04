HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt SHARE_HISTORY          # Chia sẻ lịch sử giữa các tab terminal đang mở
setopt HIST_IGNORE_ALL_DUPS   # Không lưu lại lệnh nếu nó đã tồn tại trong lịch sử
setopt HIST_REDUCE_BLANKS     # Xóa khoảng trắng thừa
alias history='fc -l 1'

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

