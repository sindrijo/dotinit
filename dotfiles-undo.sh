#!/bin/bash
set -euo pipefail

# Full undo: restore original system state
# Usage: ./dotfiles-undo.sh

dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

echo "Undoing dotfiles setup..."

# 1. Remove all files tracked by dotfiles repo
if [ -d "$HOME/.dotfiles" ]; then
    echo "Removing dotfiles..."
    dotfiles ls-tree -r HEAD --name-only | while read -r file; do
        if [ -f "$HOME/$file" ]; then
            rm "$HOME/$file"
            echo "Removed: $file"
        fi
    done
fi

# 2. Restore backed-up original files
if [ -d "$HOME/.dotfiles-backup" ]; then
    echo "Restoring original files..."
    find "$HOME/.dotfiles-backup" -type f | while read -r file; do
        dest="$HOME/${file#$HOME/.dotfiles-backup/}"
        mkdir -p "$(dirname "$dest")"
        mv "$file" "$dest"
        echo "Restored: ${file#$HOME/.dotfiles-backup/}"
    done
    rm -rf "$HOME/.dotfiles-backup"
fi

# 3. Remove the bare repo
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo "Removed ~/.dotfiles"
fi

echo "Done! System restored to original state."

