#!/usr/bin/env bash
# Common aliases (shared across bash + zsh)

#eval "$(gh copilot alias -- bash)"

# Useful Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias scratch='vim -c Scratch -c only'
alias e='vim'
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

if command -v aider >/dev/null 2>&1; then
    alias ad='aider --chat-mode ask'
    alias AD='aider --chat-mode architect'
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

