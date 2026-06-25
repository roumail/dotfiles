#!/usr/bin/env bash

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

# .zprofile content
eval "$(/opt/homebrew/bin/brew shellenv)"

## Enable a session where you are running intel architecture - check via uname -m
alias intel="env /usr/bin/arch -x86_64 /bin/zsh --login"
alias reload='source ~/.zshrc'

# Allow comments
setopt interactivecomments
# source_if_exists /usr/share/bash-completion/completions/git