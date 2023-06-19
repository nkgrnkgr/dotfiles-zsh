# -------------------------------------------------
# 環境変数設定
export PATH=$PATH
export LANG=ja_JP.UTF-8
# -------------------------------------------------

# -------------------------------------------------
# オプション設定

# History設定
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

setopt print_eight_bit

# Starship
eval "$(starship init zsh)"

# nodenv
eval "$(nodenv init -)"

# sheldon
eval "$(sheldon source)"

# zoxide
eval "$(zoxide init zsh)"

# alias
alias gui='gitui'
alias pn='pnpm'
alias cd='z'

# fzf設定
export FZF_DEFAULT_OPTS='--layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f'
export _ZO_FZF_OPTS="$_FZF_DEFAULT_OPTS --reverse --preview 'tree -C {2} | head -200'"

# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# cdr自体の設定
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
fi

# fzf cdr
function fzf-cdr() {
    # local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf)
    # if [ -n "$selected_dir" ]; then
    #     BUFFER="cd ${selected_dir}"
    #     zle accept-line
    # fi
    # zle clear-screen
    zi
    zle clear-screen
}
zle -N fzf-cdr
setopt noflowcontrol
bindkey '^q' fzf-cdr

# fzf find branch and switch branch
function sw() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf --reverse +m) &&
  git switch $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
# fzf find branch and switch branch with remote
function swr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux --reverse -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git switch $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# find file and open with vscode
function f() {
  fd . -t f -H -E 'node_modules/*' -E '.git' | fzf --preview 'bat --color=always {1}' | xargs -o code  
}

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#ripgrep-integration
# 1. Search for text in files using Ripgrep
# 2. Interactively narrow down the list using fzf
# 3. Open the file in Vim
function fg() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --bind 'enter:become(code {1})'
}
