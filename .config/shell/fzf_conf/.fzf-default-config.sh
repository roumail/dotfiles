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
    elif [[ $root == *[{}]* ]]; then
        # fzf would read braces in the prefix as field expressions
        FZF_DEFAULT_COMMAND="$_fzf_fd $type . $(printf %q "$root")" fzf "$@"
    else
        # List paths relative to root so the list doesn't repeat it on every
        # line; --accept-nth puts it back on what gets inserted
        FZF_DEFAULT_COMMAND="$_fzf_fd $type --base-directory $(printf %q "$root") --strip-cwd-prefix" \
            fzf "$@" --delimiter=$'\t' --accept-nth="${root%/}/{1}"
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

# fm [dir] [query] -> find videos under dir (default .) and print the
# picked paths, one per line. Tab marks several. Lists only video files,
# shown as "name  dir/" so long paths stay readable; the query matches both.
#   fm ~/Downloads/test | tools/run_prepare.sh
fzf_find_movie() {
    local root=${1:-.}
    local exts=(mkv mp4 m4v avi mov wmv webm mpg mpeg ts flv)
    local fd_args=(--type f --follow --exclude .evernote --exclude Library
                   --exclude '*.photoslibrary' --exclude '*.imovielibrary')
    local e
    for e in "${exts[@]}"; do fd_args+=(--extension "$e"); done

    fd "${fd_args[@]}" --format $'{/}\t{//}/\t{}' . "$root" |
        fzf --query="$2" --multi --exit-0 \
            --delimiter=$'\t' --with-nth=1,2 --accept-nth=3 \
            --tiebreak=begin,length
}

alias fm='fzf_find_movie'

