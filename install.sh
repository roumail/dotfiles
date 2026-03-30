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

# 0. Bootstrap (pure shell)
[ -r "$SHELL_CONFIG_SRC/lib/bootstrap.sh" ] && . "$SHELL_CONFIG_SRC/lib/bootstrap.sh"

echo "Installing shell configuration..."

install_local_file_from_example() {
  local example_file="$1"
  local target_file="$2"

  if [ -f "$example_file" ] && [ ! -e "$target_file" ]; then
    cp "$example_file" "$target_file"
    chmod 600 "$target_file" || true
    echo "✓ Created $target_file from example"
  fi
}

install_dotconfig_dirs() {
  echo "Symlinking .config app directories..."

  # alacritty (platform-specific)
  mkdir -p "$DOT_CONFIG_DST/alacritty"
  case "$(uname)" in
    Darwin|Linux)
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

  # bat 
  mkdir -p "$DOT_CONFIG_DST/bat"
  link_tree "$DOT_CONFIG_SRC/bat" "$DOT_CONFIG_DST/bat"
}
#
# Create ~/.config if it doesn't exist
mkdir -p "$DOT_CONFIG_DST"

# Symlink the shell config directory
link_dir "$SHELL_CONFIG_SRC" "$SHELL_CONFIG_DEST"

# Create local directory if it doesn't exist
mkdir -p "$SHELL_CONFIG_DEST/local"
echo "Bootstrapping local shell files from examples..."
for example_file in "$SHELL_CONFIG_DEST/local/"*.example; do
  [ -f "$example_file" ] || continue
  target_file="${example_file%.example}"
  install_local_file_from_example "$example_file" "$target_file"
done

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

echo ""
install_dotconfig_dirs

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
