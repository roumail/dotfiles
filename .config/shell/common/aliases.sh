#!/usr/bin/env bash
# Common aliases (shared across bash + zsh)

#eval "$(gh copilot alias -- bash)"

# Useful Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias v='vim .'
alias e='vim'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gA='git add -A'
alias gc='git commit -m'
alias gC='git commit -m "update"'
alias gfo='git fetch origin'
alias sa='source .venv/bin/activate'
alias Sa='source ../.venv/bin/activate'
alias c='clear'
alias mkdir='mkdir -p'
alias path='echo -e ${PATH//:/\\n}'
# Check if notes.sh is available in the system PATH
if command -v notes.sh >/dev/null 2>&1; then
    alias n='notes.sh'
fi

# ls aliases
alias l='ls $LS_OPTIONS -lA'
alias ll='ls $LS_OPTIONS -alF'

# Safe defaults for destructive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

