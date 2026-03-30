#!/usr/bin/env bash
# PATH configuration (shared across bash + zsh)

path_prepend "$SHELL_CONFIG_BASE/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.venv/bin"


# Add cargo to PATH if it exists
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

