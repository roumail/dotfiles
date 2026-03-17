#!/usr/bin/env bash
# https://github.com/junegunn/fzf-git.sh
# https://github.com/junegunn/fzf/wiki/Examples#git
# Log view
fzf_git_log() {
  local selection
  local commit
  local root_dir
  local default_branch
  local args
  local log_cmd
  local log_cmd_tac

  root_dir=$(git rev-parse --show-toplevel 2>/dev/null) || return
  default_branch=$(git_get_default_branch "$root_dir/.git")

  if [[ -z "$default_branch" ]]; then
    default_branch="main"
  fi
  # if [[ $# -eq 0 ]]; then
  #   args=(-n 20)
  # else
  #   args=("$@")
  # fi  
  log_cmd="git log --oneline --color=always"
  log_cmd_tac="git log --reverse --oneline --color=always"

  # log_cmd="git log --oneline --color=always ${args[*]}"
  # log_cmd_tac="git log --reverse --oneline --color=always ${args[*]}"
  selection=$(
  git log \
    --oneline \
    --color=always \
    "$@" | \
    fzf \
    --ansi \
    --no-sort \
    --prompt 'Log(stat)> ' \
    --header "enter/ctrl-o: Diff| ctrl-r: log/rebase order| ctrl-t: stat/patch" \
    --preview 'git show --stat --oneline --color=always {1}' \
    --bind 'ctrl-t:transform:
      [[ $FZF_PROMPT =~ stat ]] &&
        echo "change-prompt(${FZF_PROMPT/stat/patch})+change-preview(git show -p --color=always \{1})+refresh-preview" ||
        echo "change-prompt(${FZF_PROMPT/patch/stat})+change-preview(git show --stat --oneline --color=always \{1})+refresh-preview"
            ' \
    --bind 'ctrl-r:transform:
      [[ $FZF_PROMPT =~ Log ]] &&
        echo "change-prompt(${FZF_PROMPT/Log/Rebase})+reload(git log --reverse --oneline --color=always)" ||
        echo "change-prompt(${FZF_PROMPT/Rebase/Log})+reload(git log --oneline --color=always)"
              ' \
    --bind "enter:become(vim -c 'Git difftool -y {1}^ {1}' < /dev/tty > /dev/tty)" \
    --bind "ctrl-o:become(vim -c 'Gedit {1}' < /dev/tty > /dev/tty)" \
    --preview-window='right:60%:wrap'
  )
  # origin/main...feature
  # origin/main..HEAD - What have I changed locally compared to the remote main
  # origin/main..main - commits you have that remote doesn't have
  # main..origin/main - commits remote has that you don’t)

}
alias gll='fzf_git_log'

# pick axe
fzf_git_log_pickaxe() {
  if [[ $# == 0 ]]; then
    echo 'Error: search term was not provided.'
    return
  fi
  local selection=$(
  git log --oneline --color=always -S "$@" |
    fzf --no-multi --ansi --no-sort --no-height \
    --preview "git show --color=always {1}"
  )
  if [[ -n $selection ]]; then
    local commit=$(echo "$selection" | awk '{print $1}' | tr -d '\n')
    git show $commit
  fi
}

alias glS='fzf_git_log_pickaxe'

# https://github.com/junegunn/fzf/wiki/examples#git for more specific inspiration
