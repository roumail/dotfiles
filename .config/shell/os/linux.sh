#!/usr/bin/env bash
# Linux-specific configuration

# Setup dircolors for colored output
eval "$(dircolors)"

eval "$(fzf --bash)"
eval "$(starship init bash)"
alias reload='source ~/.bashrc'
