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
source <(fzf --zsh)
eval "$(rbenv init - zsh)"
eval "$(starship init zsh)"
# brew install zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# bindkey '^G' list-expand prevents binding to work on mac, hence removing this here
bindkey -r '^G'

_wezterm_zsh_preexec() {
  local cmd="${1%% *}"
  cmd="${cmd##*/}"
  __wezterm_set_user_var WEZTERM_PROG "$cmd"
  _wezterm_osc2_preexec "$1"
}

_wezterm_zsh_precmd() {
  __wezterm_set_user_var WEZTERM_PROG "zsh"
  _wezterm_osc2_precmd
  _wezterm_osc7_hook
}
# remove before add to avoid duplicate hooks on reload
add-zsh-hook -d preexec _wezterm_zsh_preexec 2>/dev/null
add-zsh-hook -d precmd _wezterm_zsh_precmd 2>/dev/null
add-zsh-hook preexec _wezterm_zsh_preexec
add-zsh-hook precmd _wezterm_zsh_precmd
