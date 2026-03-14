#!/usr/bin/env bash
# https://github.com/junegunn/fzf-git.sh
# Log view
fzf_git_log() {
    local selection
    local commit
    local root_dir

    root_dir=$(git rev-parse --show-toplevel 2>/dev/null) || return

    selection=$(
      git log \
          --graph \
          --format='%C(auto)%h %d %s %C(black)%C(bold)%cr' \
          --color=always \
          "$@" | \
        fzf \
          --ansi \
          --no-sort \
          --reverse \
          --no-multi \
          --preview '
              commit=$(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)
              echo "FILES:"
              git diff-tree --no-commit-id --name-only -r $commit
              echo 
              echo "STATS:"
              git show --stat --oneline $commit
              echo
              echo "PATCH:"
              git show --color=always $commit
          '
    )

    # If the user made a selection (didn't hit ESC)
    if [[ -n "$selection" ]]; then
        # Extract the commit hash
        commit=$(echo "$selection" | grep -o "[a-f0-9]\{7,\}" | head -1)
        
        # Open Vim, change to root directory, and run Fugitive's difftool
        # We use -c "cmd" for the first command and -c "cmd" for the second
        vim -c "cd $root_dir" -c "Git difftool -y ${commit}^ $commit"
    fi  
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
