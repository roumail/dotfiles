#!/usr/bin/env bash
# link-windows-certs.sh
# Link all Windows certificates into /etc/ssl/certs (WSL only)
# Must be run as root

set -euo pipefail

# Only run on WSL
if ! is_wsl; then
  echo "→ Not running on WSL, exiting."
  exit 0
fi

echo "→ Linking Windows certs into /etc/ssl/certs"

SRC_DIR="/mnt/c/projects/windows-certs-2-wsl/all-certificates"
TARGET_DIR="/etc/ssl/certs"

# Check that source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "⚠ Source directory does not exist: $SRC_DIR"
  echo "→ Nothing to link, exiting."
  exit 1
fi

for cert in "$SRC_DIR"/*; do
  [ -f "$cert" ] || continue
  filename=$(basename "$cert")
  target="$TARGET_DIR/$filename"
  link_file "$cert" "$target"
done
 
echo "→ Linking Done."

# Update CA certificates (Debian/Ubuntu)
if command -v update-ca-certificates >/dev/null 2>&1; then
  echo "→ Updating system CA certificates..."
  update-ca-certificates
fi

echo "→ Done."
