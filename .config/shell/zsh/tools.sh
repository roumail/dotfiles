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
  if [ -r "$zvm_path" ]; then
    # zsh-vi-mode overwrites keybindings from other plugins during its own init.
    # keybindings.sh's `bindkey -r '^G'` is what clears that, so it has to be
    # re-run after both stages too, not just plugins/fzf.sh.
    function zvm_after_init zvm_after_lazy_keybindings {
      source_dir "$BASE/plugins"
      source_if_exists "$BASE/$SHELL_NAME/keybindings.sh"
    }
    # Read once when the plugin is sourced, so it must be set beforehand.
    ZVM_SYSTEM_CLIPBOARD_ENABLED=true
    source "$zvm_path"
  fi
fi
