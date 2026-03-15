#!/usr/bin/env bash
# https://github.com/junegunn/fzf-git.sh
# https://github.com/junegunn/fzf/wiki/Examples#git
# Log view
fzf_git_log() {
    local selection
    local commit
    local root_dir
    local default_branch

    root_dir=$(git rev-parse --show-toplevel 2>/dev/null) || return
    default_branch=$(git_get_default_branch "$root_dir/.git")

    if [[ -z "$default_branch" ]]; then
        default_branch="main"
    fi
    if [[ $# -eq 0 ]]; then
        set -- -n 20
    fi  

    selection=$(
      git log \
          --oneline \
          --color=always \
          "$@" | \
        fzf \
          --ansi \
          --no-sort \
          --reverse \
          --prompt 'Commits(stat)> ' \
          --header "Enter: commit diff | Ctrl-o: Gedit | Ctrl-t: toggle preview" \
          --preview 'git show --stat --oneline --color=always {1}' \
          --bind 'ctrl-t:transform:
              [[ $FZF_PROMPT =~ stat ]] &&
                  echo "change-prompt(Commits(patch)> )+change-preview(git show -p --color=always {1})" ||
                  echo "change-prompt(Commits(stat)> )+change-preview(git show --stat --oneline --color=always {1} )"
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
