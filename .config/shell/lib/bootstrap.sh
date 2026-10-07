#!/usr/bin/env bash
source_dir() {
  [ -d "$1" ] || return
  # Use process substitution instead of pipe to avoid subshell
  while read -r f; do
      source_if_exists "$f"
  done < <(find "$1" -maxdepth 1 -name '*.sh' -type f)
}

path_prepend() {
    [ -d "$1" ] || return
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

path_append() {
    [ -d "$1" ] || return
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$PATH:$1" ;;
    esac
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

  # -n: replace a symlink to a directory instead of linking inside it
  if [ -L "$target" ]; then
    ln -sfn "$src" "$target"
    echo "  ↻ Refreshed symlink: $(basename "$target")"
  elif [ -e "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    # mv (not cp) also handles directories; never link if the backup failed
    if ! mv "$target" "$backup"; then
      echo "  ✗ Backup failed, left untouched: $target" >&2
      return 0
    fi
    ln -sfn "$src" "$target"
    echo "  ✓ Backed up and linked: $(basename "$target")"
  else
    ln -sfn "$src" "$target"
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
    ln -sfn "$src" "$target"
    echo "  ↻ Updated dir symlink: $(basename "$target")"
    # real file or directory
  elif [ -e "$target" ]; then
    echo "  ⚠ Directory exists: $target"
    read -p "    Replace with symlink? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
      if ! mv "$target" "$backup"; then
        echo "  ✗ Backup failed, left untouched: $target" >&2
        return 0
      fi
      ln -sfn "$src" "$target"
      echo "  ✓ Backed up and linked dir: $(basename "$target")"
    else
      echo "  → Skipped: $(basename "$target")"
    fi

  else
    ln -sfn "$src" "$target"
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
  # Already the repo's file, e.g. through a symlinked parent directory
  if [ "$target" -ef "$file" ]; then
    continue
  fi
  # Never replace a real file, but say so: it shadows the repo's version
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  ⚠ Exists, not linked: $target" >&2
    continue
  fi
  # Skip if already correct symlink
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
    continue
  fi
  ln -sfn "$file" "$dst/$rel"
done
  prune_dangling_links "$src" "$dst"
}

# Remove symlinks under $dst that point into $src but whose target no longer
# exists (e.g. a file deleted or moved in the repo after a git pull).
# Dangling links pointing elsewhere are left alone.
prune_dangling_links() {
  local src="$1"
  local dst="$2"
  [ -d "$dst" ] || return 0
  find "$dst" -type l -print0 | while IFS= read -r -d '' link; do
  target="$(readlink "$link")"
  case "$target" in
    "$src"/*)
      if [ ! -e "$link" ]; then
        rm "$link"
        echo "  ✗ Pruned dangling link: ${link#$dst/}"
      fi
      ;;
  esac
done
}
