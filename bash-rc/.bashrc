# ~/.bashrc: executed by bash(1) for non-login shells.

# vi mode
set -o vi
# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022
# https://marioyepes.com/blog/vim-setup-for-modern-web-development/#themes
export TERM=xterm-256color-italic
export LS_OPTIONS='--color=auto'
export EDITOR="vim"
# Set SHELL environment variable
export SHELL=/bin/bash
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -al'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
source ~/.fzf-config

# eval "$(gh copilot alias -- bash)"
eval "$(starship init bash)"
eval "$(fzf --bash)"
