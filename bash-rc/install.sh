#!/usr/bin/env bash
# Bootstrap script to install shell configuration

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIG_SRC="$DOTFILES_DIR/.config/shell"
SHELL_CONFIG_DEST="$HOME/.config/shell"

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
echo "Installing shell configuration..."

# Create ~/.config if it doesn't exist
mkdir -p "$HOME/.config"

# Symlink the shell config directory
if [ -L "$SHELL_CONFIG_DEST" ]; then
    echo "✓ Symlink already exists: $SHELL_CONFIG_DEST"
elif [ -e "$SHELL_CONFIG_DEST" ]; then
    echo "⚠ Warning: $SHELL_CONFIG_DEST exists but is not a symlink"
    read -p "Remove and replace with symlink? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$SHELL_CONFIG_DEST"
        ln -sf "$SHELL_CONFIG_SRC" "$SHELL_CONFIG_DEST"
        echo "✓ Created symlink: $SHELL_CONFIG_DEST -> $SHELL_CONFIG_SRC"
    fi
else
    ln -sf "$SHELL_CONFIG_SRC" "$SHELL_CONFIG_DEST"
    echo "✓ Created symlink: $SHELL_CONFIG_DEST -> $SHELL_CONFIG_SRC"
fi

# Create local directory if it doesn't exist
mkdir -p "$SHELL_CONFIG_DEST/local"

# Detect which shell RC we’re installing
if [ -n "$ZSH_VERSION" ]; then
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
        alacritty.toml|alacritty.win.toml)
            continue
            ;;
    esac

    link_file "$config" "$HOME/.config/$filename"
done

# TODO: handle OS switch for dotconfig alacritty
case "$(uname)" in
    Darwin)
        link_file \
            "$SHELL_CONFIG_SRC/dotconfig/alacritty.toml" \
            "$HOME/.config/alacritty.toml"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        link_file \
            "$SHELL_CONFIG_SRC/dotconfig/alacritty.win.toml" \
            "$HOME/.config/alacritty.toml"
        ;;
esac

echo ""
echo "Installation complete! Run 'source $RC_FILE' or restart your shell."
