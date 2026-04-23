#!/usr/bin/env bash
# Linux-specific configuration

# Setup dircolors for colored output
eval "$(dircolors)"

eval "$(fzf --bash)"
eval "$(starship init bash)"
alias reload='source ~/.bashrc'
source_if_exists /usr/share/bash-completion/completions/git


# We check if the hooks are already in PROMPT_COMMAND to avoid double-printing
# if you source your .bashrc multiple times.
# Append the function to PROMPT_COMMAND this way anything directory changes, we execute this command
if [[ ! "$PROMPT_COMMAND" =~ "_wezterm_osc7_hook" ]]; then
  PROMPT_COMMAND="_wezterm_osc7_hook; $PROMPT_COMMAND"
fi

