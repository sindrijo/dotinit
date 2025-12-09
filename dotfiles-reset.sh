#!/bin/bash
set -euo pipefail

# Dev reset: remove tracking, ready for re-testing
# Usage: ./dotfiles-reset.sh

echo "Resetting dotfiles setup..."

# Remove the bare repo
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo "Removed ~/.dotfiles"
fi

# Remove backups (not needed for re-testing)
if [ -d "$HOME/.dotfiles-backup" ]; then
    rm -rf "$HOME/.dotfiles-backup"
    echo "Removed ~/.dotfiles-backup"
fi

echo "Reset complete. Ready to run dotfiles.sh again."

