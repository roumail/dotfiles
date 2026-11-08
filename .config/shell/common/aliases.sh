#!/usr/bin/env bash
# Common aliases (shared across bash + zsh)

#eval "$(gh copilot alias -- bash)"

# Useful Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias scratch='vim -c Scratch -c only'
alias e='vim'
alias d='vim +DiffThis'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gA='git add -A'
alias gc='git commit -m'
alias gC='git commit -m "update"'
alias sa='source .venv/bin/activate'
alias Sa='source ../.venv/bin/activate'
alias c='clear'
alias mkdir='mkdir -p'
alias path='echo -e ${PATH//:/\\n}'
if command -v notes.sh >/dev/null 2>&1; then
    alias n='notes.sh'
fi

# dj [duration [label]] -> today's daily journal, $NOTE_DIR/journal/YYYY-MM-DD.md,
# in vim with Goyo. In wezterm it also pins the tab and starts a timer
# (default "5m journal"); see DJ_SESSION in .wezterm.lua
dj() {
    local dir="${NOTE_DIR:?dj: NOTE_DIR not set}/journal"
    local file
    file="$dir/$(date +%F).md"
    command mkdir -p "$dir" || return
    [ -e "$file" ] || printf '# %s\n\n' "$(date '+%A %d %B %Y')" > "$file"
    local wez=
    if [ -n "${WEZTERM_PANE-}" ] && command -v __wezterm_set_user_var >/dev/null 2>&1; then
        wez=1
        __wezterm_set_user_var DJ_SESSION "${*:-5m journal}"
    fi
    vim +'normal! G' +Goyo "$file"
    [ -n "$wez" ] && __wezterm_set_user_var DJ_SESSION ""
    return 0
}

if command -v aider >/dev/null 2>&1; then
    alias ad='aider --chat-mode ask'
    alias AD='aider --chat-mode architect'
fi

# md notes.md -> read rendered markdown in a pager (same as <localleader>p in vim, without opening vim)
if command -v glow >/dev/null 2>&1; then
    alias md='PAGER="less -rc~" glow -p -w "$COLUMNS"'
fi

# md2pdf notes.md [extra pandoc args] -> notes.pdf (needs: brew install pandoc, plus a PDF engine e.g. brew install --cask basictex)
if command -v pandoc >/dev/null 2>&1; then
    md2pdf() { pandoc "$1" -o "${1%.*}.pdf" "${@:2}"; }
fi

# yank file...  or  cmd | yank -> system clipboard
yank() {
    local copy
    if command -v pbcopy >/dev/null 2>&1; then copy=pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then copy=wl-copy
    elif command -v xclip >/dev/null 2>&1; then copy='xclip -selection clipboard'
    else echo "yank: no clipboard command found" >&2; return 1
    fi
    if [[ $# -gt 0 ]]; then cat -- "$@" | $copy; else $copy; fi
}

# ls aliases
alias l='ls $LS_OPTIONS -lA'
alias ll='ls $LS_OPTIONS -alF'

# Safe defaults for destructive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

