#!/usr/bin/env bash

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# .zprofile content
eval "$(/opt/homebrew/bin/brew shellenv)"

## Enable a session where you are running intel architecture - check via uname -m
alias intel="env /usr/bin/arch -x86_64 /bin/zsh --login"
alias reload='source ~/.zshrc'

# Allow comments
setopt interactivecomments

# source_if_exists /usr/share/bash-completion/completions/git
source <(fzf --zsh)
eval "$(rbenv init - zsh)"
eval "$(starship init zsh)"
# brew install zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# bindkey '^G' list-expand prevents binding to work on mac, hence removing this here
bindkey -r '^G'
tmux-window-name() {
  [[ -z "$TMUX" ]] && return
  ($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

add-zsh-hook chpwd tmux-window-name
