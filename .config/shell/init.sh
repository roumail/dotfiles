#!/usr/bin/env bash
BASE="${SHELL_CONFIG_BASE:-$HOME/.config/shell}"

# 0. Bootstrap (pure shell)
[ -r "$BASE/lib/bootstrap.sh" ] && . "$BASE/lib/bootstrap.sh"
[ -r "$BASE/common/env.sh" ] && . "$BASE/common/env.sh"
[ -r "$BASE/common/path.sh" ] && . "$BASE/common/path.sh"
[ -r "$BASE/common/git.sh" ] && . "$BASE/common/git.sh"

# interactive guard - exit if not running interactively
[[ $- != *i* ]] && return

# 1. Common 
COMMON_CORE=(
  functions.sh
  aliases.sh
)

for plugin in "${COMMON_CORE[@]}"; do
  source_if_exists "$BASE/common/$plugin" 
done

USER_SHELL=$(basename "$SHELL")


if [ "$USER_SHELL" = "zsh" ]; then
  SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_NAME="bash"
fi

echo "Loading shell config for $SHELL_NAME"
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
