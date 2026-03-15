#!/usr/bin/env bash
# Bootstrap script to install shell configuration

set -e
# set -x
# set +e
# set -ex

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG_SRC="$DOTFILES_DIR/.config/shell"
VIM_CONFIG_SRC="$DOTFILES_DIR/vim-rc"
TMUX_CONFIG_SRC="$DOTFILES_DIR/tmux"
DOT_CONFIG_SRC="$DOTFILES_DIR/config"
DOT_CONFIG_DST="$HOME/.config"
SHELL_CONFIG_DEST="$DOT_CONFIG_DST/shell"
USER_SHELL=$(basename "$SHELL")

link_file() {
  local src="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    ln -sf "$src" "$target"
    echo "  ↻ Refreshed symlink: $(basename "$target")"
  elif [ -e "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$target" "$backup"
    ln -sf "$src" "$target"
    echo "  ✓ Backed up and linked: $(basename "$target")"
  else
    ln -sf "$src" "$target"
    echo "  ✓ Linked: $(basename "$target")"
  fi
}

link_dir() {
  local src="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  # symlink (file or dir)
  if [ -L "$target" ]; then
    unlink "$target"
    ln -sf "$src" "$target"
    echo "  ↻ Updated dir symlink: $(basename "$target")"
    # real file or directory
  elif [ -e "$target" ]; then
    echo "  ⚠ Directory exists: $target"
    read -p "    Replace with symlink? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
      mv "$target" "$backup"
      ln -sf "$src" "$target"
      echo "  ✓ Backed up and linked dir: $(basename "$target")"
    else
      echo "  → Skipped: $(basename "$target")"
    fi

  else
    ln -sf "$src" "$target"
    echo "  ✓ Linked dir: $(basename "$target")"
  fi
}

echo "Installing shell configuration..."

# Create ~/.config if it doesn't exist
mkdir -p "$DOT_CONFIG_DST"

# Symlink the shell config directory
link_dir "$SHELL_CONFIG_SRC" "$SHELL_CONFIG_DEST"

# Create local directory if it doesn't exist
mkdir -p "$SHELL_CONFIG_DEST/local"

# Detect which shell RC we’re installing
if [ "$USER_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
  SHELL_NAME="zsh"
else
  RC_FILE="$HOME/.bashrc"
  SHELL_NAME="bash"
fi

echo "Installing $SHELL_NAME entrypoint: $RC_FILE"

# Backup existing RC if it exists and is not a symlink
if [ -f "$RC_FILE" ] && [ ! -L "$RC_FILE" ]; then
  cp "$RC_FILE" "${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "✓ Backed up existing $RC_FILE"
fi

# Write new RC 
cat > "$RC_FILE" <<EOF
#!/usr/bin/env $SHELL_NAME
# Managed by dotfiles - do not edit

export SHELL_CONFIG_BASE="\$HOME/.config/shell"
BOOTLOADER="\$SHELL_CONFIG_BASE/init.sh"
[ -f "\$BOOTLOADER" ] && source "\$BOOTLOADER"
EOF

echo "✓ Installed new $RC_FILE"
# Symlink dotfiles from dots/ to $HOME
echo ""
echo "Symlinking dotfiles..."
for dotfile in "$SHELL_CONFIG_SRC/dots/".??*; do
  [ -f "$dotfile" ] || continue
  filename=$(basename "$dotfile")
  link_file "$dotfile" "$HOME/$filename"
done

echo "Symlinking .config files..."
for config in "$SHELL_CONFIG_SRC/dotconfig/"*; do
  [ -f "$config" ] || continue
  filename=$(basename "$config")
  link_file "$config" "$HOME/.config/$filename"
done

mkdir -p "$DOT_CONFIG_DST/alacritty"
mkdir -p "$DOT_CONFIG_DST/bat"

case "$(uname)" in
  Darwin)
    link_file \
      "$DOT_CONFIG_SRC/alacritty/alacritty.unix.toml" \
      "$DOT_CONFIG_DST/alacritty/alacritty.toml"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    link_file \
      "$DOT_CONFIG_SRC/alacritty/alacritty.win.toml" \
      "$DOT_CONFIG_DST/alacritty/alacritty.toml"
    ;;
esac

link_file "$DOT_CONFIG_SRC/bat/bat.conf" "$DOT_CONFIG_DST/bat/bat.conf"

link_tree() {
  local src="$1"
  local dst="$2"
  find "$src" -type f | while read -r file; do
  rel="${file#$src/}"
  target="$dst/$rel"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    continue
  fi
  # Skip if already correct symlink
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
    continue
  fi
  ln -sf "$file" "$dst/$rel"
done
}

echo ""

echo "Setting up Vim..."
mkdir -p "$HOME/.vim"

# Runtime dirs
mkdir -p "$HOME/.vim/backup"
mkdir -p "$HOME/.vim/swap"

link_tree "$VIM_CONFIG_SRC" "$HOME/.vim"

echo ""
echo "Setting up tmux..."

mkdir -p "$HOME/.tmux/plugins"
mkdir -p "$HOME/.tmux/resurrect"

# Link tmux.conf
link_file "$TMUX_CONFIG_SRC/.tmux.conf" "$HOME/.tmux.conf"


echo ""
echo "Setting up .config.."
DOT_CONFIG_SRC="$DOTFILES_DIR/config"

echo "Installation complete! Run 'source $RC_FILE' or restart your shell."
