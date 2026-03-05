#!/usr/bin/env bash
# fzf plugin configuration (shared across bash + zsh)
# Retrieved via https://github.com/junegunn/fzf-git.sh

FZF_CONF="$SHELL_CONFIG_BASE/fzf_conf"

# fzf-git.sh for git fuzzy operations
if [[ -f "$FZF_CONF/fzf-git.sh" ]]; then
    source "$FZF_CONF/fzf-git.sh"
fi

# Load fzf customizations
# The script defaults to CTRL-G followed by:
# b (branches), f (files), t (tags), r (remotes), h (hashes)
if [[ -f "$FZF_CONF/.fzf-default-config.sh" ]]; then
    source "$FZF_CONF/.fzf-default-config.sh"
fi

if [[ -f "$FZF_CONF/.fzf-git-config.sh" ]]; then
    source "$FZF_CONF/.fzf-git-config.sh"
fi
