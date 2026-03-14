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
          --expect=enter,ctrl-o \
          --header "Enter: commit diff | Ctrl-o: Gedit | Ctrl-t: toggle preview" \
          --preview 'git show --stat --oneline --color=always {1}' \
          --bind 'ctrl-t:transform:
              [[ $FZF_PROMPT =~ stat ]] &&
                  echo "change-prompt(Commits(patch)> )+change-preview(git show -p --color=always {1})" ||
                  echo "change-prompt(Commits(stat)> )+change-preview(git show --stat --oneline --color=always {1} )"
          ' \
          --preview-window='right:60%:wrap'
    )

    # If the user made a selection (didn't hit ESC)
    if [[ -n "$selection" ]]; then
        # Extract the commit hash
        key=$(echo "$selection" | head -1)
        line=$(echo "$selection" | tail -1)

        commit=$(echo "$line" | awk '{print $1}')
        case "$key" in
            ctrl-o)
                vim -c "cd $root_dir" \
                    -c "Gedit ${commit}"
                # vim -c "cd $root_dir" \
                #     -c "Git difftool -y ${default_branch}...${commit}"
                ;;
            *)
                vim -c "cd $root_dir" \
                    -c "Git difftool -y ${commit}^ ${commit}"
                ;;
        esac
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
