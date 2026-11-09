#!/usr/bin/env bash

# What every fzf listing shows: Ctrl-T, Alt-C, ** and, through the variables
# below, Vim's <c-x><c-f> and <c-x><c-d>. Hidden files and symlinks in; .git,
# __pycache__ and ignored files out.
_fzf_fd='fd --hidden --follow --exclude .git --exclude __pycache__'

export FZF_DEFAULT_COMMAND="$_fzf_fd --type f --strip-cwd-prefix"

# top-down 75%: comes from the bottom
# --height 75% -
export FZF_DEFAULT_OPTS='
  --multi --reverse
  --bind ctrl-f:page-down,ctrl-b:page-up
'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND="$_fzf_fd --type d --strip-cwd-prefix"

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

# Options for directory completion (e.g. cd **<TAB>): --multi from
# FZF_DEFAULT_OPTS would let extra Tabs mark several directories for cd
export FZF_COMPLETION_DIR_OPTS='--no-multi'

# ** lists with fd, through fzf's own source command: fzf stops that the moment
# a selection is made, where a pipe from _fzf_compgen_* would hold Enter until
# fd finishes. The walker options fzf's completion passes say what to list.
_fzf_comprun() {
    local previous= root= type= arg
    shift
    for arg in "$@"; do
        case $arg in
            --walker-root=*) root=${arg#--walker-root=} ;;
        esac
        if [[ $previous == --walker && $arg == dir,* ]]; then
            type='--type d'
        fi
        previous=$arg
    done

    if [[ -z $root ]]; then
        fzf "$@"
    elif [[ $root == . ]]; then
        FZF_DEFAULT_COMMAND="$_fzf_fd $type --strip-cwd-prefix" fzf "$@"
    else
        FZF_DEFAULT_COMMAND="$_fzf_fd $type . $(printf %q "$root")" fzf "$@"
    fi
}

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

