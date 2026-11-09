#!/usr/bin/env bash

# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
# include hidden files and follow symlinks, exclude git
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

# top-down 75%: comes from the bottom
# --height 75% -
export FZF_DEFAULT_OPTS='
  --multi --reverse
  --bind ctrl-f:page-down,ctrl-b:page-up
'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'

export FZF_ALT_C_OPTS="--preview 'tree -C {} | bat --line-range :100'"

export FZF_CTRL_R_OPTS="
--bind 'ctrl-y:execute-silent(echo -n {2..} |
   (command -v pbcopy >/dev/null && pbcopy ||
   command -v wl-copy >/dev/null && yank))+abort'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard'"

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Options for path completion (e.g. vim **<TAB>)
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

# Options for directory completion (e.g. cd **<TAB>)
export FZF_COMPLETION_DIR_OPTS='--no-multi --walker dir,follow,hidden'

# Find a file and edit it using declared editor
fzf_find_edit() {
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
    )
    if [[ -n "$file" ]]; then
        $EDITOR "$file"
    fi
}

alias fe='fzf_find_edit'

fzf_change_directory() {
    local directory=$(
      fd --type d | \
        fzf --query="$1" --no-multi --select-1 --exit-0 \
            --preview 'tree -C {} | bat --line-range :100'
            # --preview 'tree -C {} | head -100'
    )
    if [[ -n $directory ]]; then
        cd "$directory"
    fi
}

alias fcd='fzf_change_directory'

