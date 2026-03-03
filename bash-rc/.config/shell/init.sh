#!/usr/bin/env bash

# interactive guard - exit if not running interactively
[[ $- != *i* ]] && return

BASE="${SHELL_CONFIG_BASE:-$HOME/.config/shell}"

# Detect shell once
if [ -n "$ZSH_VERSION" ]; then
  SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_NAME="bash"
fi

echo "Loading shell config for $SHELL_NAME"

source_if_exists() {
  [ -r "$1" ] && source "$1"
}

source_dir() {
  [ -d "$1" ] || return
  for f in "$1"/*.sh; do
    [ -e "$f" ] || continue
    source_if_exists "$f"
  done
}

# 1. Common (shared across shells) - Order matters
COMMON_CORE=(
  env.sh
  path.sh
  functions.sh
  aliases.sh
)

for plugin in "${COMMON_CORE[@]}"; do
  source_if_exists "$BASE/common/$plugin" 
done

# 2. Bash-specific
source_dir "$BASE/$SHELL_NAME"

# 3. OS-specific
case "$(uname)" in
  Darwin) source_if_exists "$BASE/os/macos.sh" ;;
  Linux)  source_if_exists "$BASE/os/linux.sh" ;;
esac

# 4. Shared plugins (fzf, etc.)
source_dir "$BASE/plugins"

# 5. Shell specific plugins 
source_dir "$BASE/$SHELL_NAME/plugins"

# 6. Local overrides 
source_dir "$BASE/local"
