#!/usr/bin/env bash
# PATH configuration (shared across bash + zsh)

# Add shell config bin directory to PATH
if [ -d "$SHELL_CONFIG_BASE/bin" ]; then
    export PATH="$SHELL_CONFIG_BASE/bin:$PATH"
fi

# User bin
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# Local bin
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Local bin
[ -d "$HOME/.venv/bin" ] && export PATH="$HOME/.venv/bin:$PATH"
#
# Add cargo to PATH if it exists
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

