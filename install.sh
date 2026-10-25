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
PROJECTS_DIR="$HOME/projects"
EVERYTHING_FZF_DIR="$PROJECTS_DIR/everything.fzf"

check_required_tools() {
  # cargo, npm, coreutils (mac - tac)
  local required_tools=("fzf" "uv" "bat" "starship" "wezterm" "git" "vim" "curl" "fd" "rg" "delta" "gh")
  local os_tools=()

  case "$(uname)" in
    Darwin)
      os_tools+=("brew")
      ;;
    Linux)
      :
      ;;
  esac

  local missing_tools=()

  for tool in "${required_tools[@]}" "${os_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing_tools+=("$tool")
    fi
  done

  if [ ${#missing_tools[@]} -gt 0 ]; then
    echo "✗ Installation failed: required tools not found:"
    printf "  - %s\n" "${missing_tools[@]}"
    exit 1
  fi
}

# Detect which shell RC we’re installing
if [ "$USER_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
  SHELL_NAME="zsh"
else
  RC_FILE="$HOME/.bashrc"
  SHELL_NAME="bash"
fi

# Check required tools FIRST, before any side effects
check_required_tools

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

  # # alacritty (platform-specific)
  # mkdir -p "$DOT_CONFIG_DST/alacritty"
  # case "$(uname)" in
  #   Darwin|Linux)
  #     link_file \
  #       "$DOT_CONFIG_SRC/alacritty/alacritty.unix.toml" \
  #       "$DOT_CONFIG_DST/alacritty/alacritty.toml"
  #     ;;
  #   MINGW*|MSYS*|CYGWIN*)
  #     link_file \
  #       "$DOT_CONFIG_SRC/alacritty/alacritty.win.toml" \
  #       "$DOT_CONFIG_DST/alacritty/alacritty.toml"
  #     ;;
  # esac

  # bat
  mkdir -p "$DOT_CONFIG_DST/bat"
  link_tree "$DOT_CONFIG_SRC/bat" "$DOT_CONFIG_DST/bat"

  # wezterm
  mkdir -p "$DOT_CONFIG_DST/wezterm"
  link_tree "$DOT_CONFIG_SRC/wezterm" "$DOT_CONFIG_DST/wezterm"

  # vim-prompts rules, named by git config (config/agents/README.md)
  mkdir -p "$DOT_CONFIG_DST/vim-prompts"
  link_tree "$DOT_CONFIG_SRC/vim-prompts" "$DOT_CONFIG_DST/vim-prompts"

  # claude code reads user settings from ~/.claude, not ~/.config
  link_file "$DOT_CONFIG_SRC/claude/settings.json" "$HOME/.claude/settings.json"
  # hooks settings.json runs, e.g. guard-git.py (each repo's agents.push, no PRs)
  mkdir -p "$HOME/.claude/hooks"
  link_tree "$DOT_CONFIG_SRC/claude/hooks" "$HOME/.claude/hooks"

  # agent skills, shared and this machine's own (local/skills), for claude
  # code and copilot cli
  mkdir -p "$DOT_CONFIG_SRC/agents/skills" "$DOT_CONFIG_SRC/agents/local/skills"
  local skills_dir
  for skills_dir in "$HOME/.claude/skills" "$HOME/.copilot/skills"; do
    mkdir -p "$skills_dir"
    link_tree "$DOT_CONFIG_SRC/agents/skills" "$skills_dir"
    link_tree "$DOT_CONFIG_SRC/agents/local/skills" "$skills_dir"
  done

  install_agent_instructions
}

# Agent rules: the shared AGENTS.md, then this machine's local/AGENTS.md,
# written as each CLI's user instructions
install_agent_instructions() {
  local src="$DOT_CONFIG_SRC/agents"
  local header="<!-- Managed by dotfiles: edit config/agents/AGENTS.md or local/AGENTS.md, then run install.sh -->"
  local content target

  install_local_file_from_example "$src/local/AGENTS.md.example" "$src/local/AGENTS.md"
  content="$header"$'\n\n'"$(cat "$src/AGENTS.md")"
  if [ -f "$src/local/AGENTS.md" ]; then
    content+=$'\n\n'"$(cat "$src/local/AGENTS.md")"
  fi

  for target in "$HOME/.claude/CLAUDE.md" "$HOME/.copilot/copilot-instructions.md"; do
    mkdir -p "$(dirname "$target")"
    if [ -f "$target" ] && [ "$(cat "$target")" = "$content" ]; then
      echo "  ✓ $(basename "$target") already up to date"
      continue
    fi
    # Keep a hand-written file (one without the header) before replacing it
    if [ -s "$target" ] && [ "$(head -n 1 "$target")" != "$header" ]; then
      backup_file cp "$target"
      echo "  ✓ Backed up existing $(basename "$target")"
    fi
    printf '%s\n' "$content" > "$target"
    echo "  ✓ Wrote $target"
  done
}

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

echo "Installing $SHELL_NAME entrypoint: $RC_FILE"

RC_CONTENT=$(cat <<EOF
#!/usr/bin/env $SHELL_NAME
# Managed by dotfiles - do not edit

export SHELL_CONFIG_BASE="\$HOME/.config/shell"
BOOTLOADER="\$SHELL_CONFIG_BASE/init.sh"
[ -f "\$BOOTLOADER" ] && source "\$BOOTLOADER"
EOF
)

if [ -f "$RC_FILE" ] && [ "$(cat "$RC_FILE")" = "$RC_CONTENT" ]; then
  echo "✓ $RC_FILE already up to date"
else
  # Backup existing RC if it exists and is not a symlink
  if [ -f "$RC_FILE" ] && [ ! -L "$RC_FILE" ]; then
    backup_file cp "$RC_FILE"
    echo "✓ Backed up existing $RC_FILE"
  fi

  printf '%s\n' "$RC_CONTENT" > "$RC_FILE"
  echo "✓ Installed new $RC_FILE"
fi

# Symlink dotfiles from dots/ to $HOME
echo ""
echo "Symlinking dotfiles..."
for dotfile in "$SHELL_CONFIG_SRC/dots/".??*; do
  [ -f "$dotfile" ] || continue
  filename=$(basename "$dotfile")
  link_file "$dotfile" "$HOME/$filename"
done
echo ""
echo "Symlinking shell-specific dotfiles..."
case "$SHELL_NAME" in
  bash)
    if [ -f "$SHELL_CONFIG_SRC/bash/dots/.inputrc" ]; then
      link_file "$SHELL_CONFIG_SRC/bash/dots/.inputrc" "$HOME/.inputrc"
    fi
    ;;
  zsh)
    # Add zsh-only links here if needed later
    ;;
esac
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


if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
link_tree "$VIM_CONFIG_SRC" "$HOME/.vim"
link_file "$VIM_CONFIG_SRC/.vimrc" "$HOME/.vimrc"

# Add fzf helpers
echo ""
echo "Setting up everything.fzf..."
mkdir -p "$PROJECTS_DIR"
if [ ! -d "$EVERYTHING_FZF_DIR/.git" ]; then
  git clone https://github.com/roumail/everything.fzf "$EVERYTHING_FZF_DIR"
else
  git -C "$EVERYTHING_FZF_DIR" pull --ff-only || true
fi

mkdir -p "$HOME/.local/bin"
for tool in docker.fzf pr.fzf rg.fzf; do
  if [ -f "$EVERYTHING_FZF_DIR/$tool" ]; then
    link_file "$EVERYTHING_FZF_DIR/$tool" "$HOME/.local/bin/$tool"
  else
    echo "  ⚠ Not found in everything.fzf: $tool"
  fi
done

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
