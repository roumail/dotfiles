#!/usr/bin/env bash

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

#eval "$(rbenv init - zsh)"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# brew install zsh-vi-mode
if command -v brew >/dev/null 2>&1; then
  zvm_path="$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  [ -r "$zvm_path" ] && source "$zvm_path"
fi
