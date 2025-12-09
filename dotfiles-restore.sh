#!/bin/bash
set -euo pipefail

# Restore original files after dotfiles setup
# Usage: ./dotfiles-restore.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Restore backed up files first
if [ -d "$HOME/.dotfiles-backup" ]; then
    echo "Restoring backed up files..."
    find "$HOME/.dotfiles-backup" -type f | while read -r file; do
        dest="$HOME/${file#$HOME/.dotfiles-backup/}"
        mkdir -p "$(dirname "$dest")"
        mv "$file" "$dest"
        echo "Restored: ${file#$HOME/.dotfiles-backup/}"
    done
    rm -rf "$HOME/.dotfiles-backup"
else
    echo "No backup found at ~/.dotfiles-backup"
fi

# Then run uninit
"$SCRIPT_DIR/dotfiles-uninit.sh"

