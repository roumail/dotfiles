#!/usr/bin/env bash
source_dir() {
  [ -d "$1" ] || return
  # Use process substitution instead of pipe to avoid subshell
  while read -r f; do
      source_if_exists "$f"
  done < <(find "$1" -maxdepth 1 -name '*.sh' -type f)
}

is_wsl() {
  # Check if running on WSL
  if [ ! -f /proc/version ]; then
    return 1
  fi
  grep -qi microsoft /proc/version
}

source_if_exists() {
  [ -r "$1" ] && source "$1"
}

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
