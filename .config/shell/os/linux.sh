#!/usr/bin/env bash
# Linux-specific configuration

# Setup dircolors for colored output
eval "$(dircolors)"

eval "$(fzf --bash)"
eval "$(starship init bash)"
alias reload='source ~/.bashrc'
source_if_exists /usr/share/bash-completion/completions/git
_tmux_window_name_hook() {
    if [[ -n "$TMUX" && -n "$TMUX_PLUGIN_MANAGER_PATH" ]]; then
        ("$TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py" &)
    fi
}

# Append the function to PROMPT_COMMAND this way anything directory changes, we execute this command
PROMPT_COMMAND="_tmux_window_name_hook; $PROMPT_COMMAND"
