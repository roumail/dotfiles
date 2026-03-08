#!/usr/bin/env bash
# Bootstrap script to install shell configuration

set -e
# set -x
# set +e
# set -ex

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG_SRC="$DOTFILES_DIR/.config/shell"
VIM_CONFIG_SRC="$DOTFILES_DIR/vim-rc"
SHELL_CONFIG_DEST="$HOME/.config/shell"
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

    if [ -L "$target" ]; then
        ln -sf "$src" "$target"
        echo "  ↻ Updated dir symlink: $(basename "$target")"
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
mkdir -p "$HOME/.config"

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
    case "$filename" in
        alacritty.unix.toml|alacritty.win.toml)
            continue
            ;;
    esac

    link_file "$config" "$HOME/.config/$filename"
done

case "$(uname)" in
    Darwin)
        link_file \
            "$SHELL_CONFIG_SRC/dotconfig/alacritty.unix.toml" \
            "$HOME/.config/alacritty.toml"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        link_file \
            "$SHELL_CONFIG_SRC/dotconfig/alacritty.win.toml" \
            "$HOME/.config/alacritty.toml"
        ;;
esac

echo ""

echo "Setting up Vim..."
# TODO: Current approach is error prone, use a link tree appraoch instead
link_tree() {
    local src="$1"
    local dst="$2"

    cd "$src" || return

    find . -type f | while read -r file; do
        mkdir -p "$(dirname "$dst/$file")"
        ln -sf "$src/$file" "$dst/$file"
    done
}
mkdir -p "$HOME/.vim"

# Runtime dirs
mkdir -p "$HOME/.vim/backup"
mkdir -p "$HOME/.vim/swap"
mkdir -p "$HOME/.vim/after/colors"
mkdir -p "$HOME/.vim/after/ftplugin"
 
# Owned config
link_dir \
  "$VIM_CONFIG_SRC/vim-rc/custom" \
  "$HOME/.vim/custom"

# Structured files
link_file \
  "$VIM_CONFIG_SRC/after/ftplugin/qf.vim" \
  "$HOME/.vim/after/ftplugin/qf.vim"

link_file \
  "$VIM_CONFIG_SRC/after/colors/palenight.vim" \
  "$HOME/.vim/after/colors/palenight.vim"

link_file \
  "$VIM_CONFIG_SRC/vim-rc/autoload/lsp/ui/vim.vim" \
  "$HOME/.vim/autoload/lsp/ui/vim.vim"
 

echo "Installation complete! Run 'source $RC_FILE' or restart your shell."
