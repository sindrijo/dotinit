#!/bin/bash
set -euo pipefail

# Undo dotfiles setup (for development/testing)
# Usage: ./dotfiles-uninit.sh

echo "Removing dotfiles setup..."

# Remove the bare repository
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo "Removed ~/.dotfiles"
fi

# Remove backup directory
if [ -d "$HOME/.dotfiles-backup" ]; then
    rm -rf "$HOME/.dotfiles-backup"
    echo "Removed ~/.dotfiles-backup"
fi

# Remove dotfiles alias from .bashrc
if grep -q "alias dotfiles=" ~/.bashrc 2>/dev/null; then
    sed -i '/alias dotfiles=/d' ~/.bashrc
    echo "Removed dotfiles alias from ~/.bashrc"
fi

echo "Done! You can now re-run the bootstrap script."
