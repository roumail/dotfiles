#!/usr/bin/env bash
# Common aliases (shared across bash + zsh)

#eval "$(gh copilot alias -- bash)"

alias ..='cd ..'
alias ...='cd ...'

# ls aliases
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -al'
alias l='ls $LS_OPTIONS -lA'

# Safe defaults for destructive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
