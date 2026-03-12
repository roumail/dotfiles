#!/usr/bin/env bash
# Common environment variables (shared across bash + zsh)

# Detect platform
[ -f /proc/sys/fs/binfmt_misc/WSLInterop ] && export IS_WSL=1 || export IS_WSL=0
[[ "$OSTYPE" == "darwin"* ]] && export IS_MAC=1 || export IS_MAC=0

export TERM=xterm-256color
export XDG_CONFIG_HOME="$HOME/.config/"
# #export TERM=xterm-256color-italic 
export EDITOR="vim"
export SHELL=/bin/bash

# Set BROWSER based on platform
if [ "$IS_WSL" -eq 1 ]; then
    export BROWSER="/mnt/c/WINDOWS/explorer.exe"
elif [ "$IS_MAC" -eq 1 ]; then
    export SHELL=/bin/zsh
fi

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Colors for ls
export LS_OPTIONS='--color=auto'
export BAT_THEME="Monokai Extended Origin"
export BAT_CONFIG_PATH="$HOME/.config/bat/bat.conf"
export BAT_STYLE="numbers,changes,header,rule,snip"
export PYTHONSTARTUP=$HOME/.startup.py
# export BAT_STYLE="full"
