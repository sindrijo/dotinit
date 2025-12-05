#!/bin/bash
set -euo pipefail

# Bootstrap dotfiles on a new system (optimized for WSL)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash -s -- X

# Dry-run mode (default). Pass 'X' or '--execute' to actually run commands
DRY_RUN=true
if [[ "${1:-}" == "X" ]] || [[ "${1:-}" == "--execute" ]]; then
    DRY_RUN=false
fi

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE - No changes will be made. Pass 'X' to execute."
    echo ""
fi

# Helper function to run commands conditionally
run() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] $*"
    else
        "$@"
    fi
}

# Check if dotfiles are already set up
if [ -d "$HOME/.dotfiles" ]; then
    echo "Error: $HOME/.dotfiles already exists."
    echo "If you want to re-run the bootstrap, remove it first:"
    echo "  rm -rf ~/.dotfiles"
    exit 1
fi

# Configure git to use Windows credential manager (if available, for WSL)
CREDENTIAL_MANAGER="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
if [ -f "$CREDENTIAL_MANAGER" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] git config --global credential.helper \"$CREDENTIAL_MANAGER\""
    else
        git config --global credential.helper "$CREDENTIAL_MANAGER"
    fi
fi

# Clone dotfiles repo (using HTTPS - credential manager handles auth)
DOTFILES_REPO="https://github.com/sindrijo/dotfiles.git"
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] git clone --bare $DOTFILES_REPO $HOME/.dotfiles"
else
    git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles"
fi

dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

run mkdir -p ~/.dotfiles-backup

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would check for existing dotfiles and back them up"
    echo "[DRY RUN] dotfiles checkout (first attempt to identify conflicts)"
else
    # Backup ALL conflicting files (git indents them with tabs)
    # The pattern matches any tab-indented line from git's error output
    dotfiles checkout 2>&1 | awk '/^\t/{gsub(/^\t/, ""); print}' | while read -r file; do
        if [ -e "$HOME/$file" ]; then
            mkdir -p "$(dirname "$HOME/.dotfiles-backup/$file")"
            mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
            echo "Backed up: $file"
        fi
    done || true
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] dotfiles checkout"
else
    dotfiles checkout
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] dotfiles config --local status.showUntrackedFiles no"
else
    dotfiles config --local status.showUntrackedFiles no
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] echo \"alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'\" >> ~/.bashrc"
else
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.bashrc
fi

# Install Devbox for package management
echo ""
echo "Installing Devbox..."
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] curl -fsSL https://get.jetify.com/devbox | bash"
    echo "[DRY RUN] devbox global install"
else
    curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
    # Source devbox to make it available
    export PATH="$HOME/.nix-profile/bin:$PATH"
    if [ -f "$HOME/.local/bin/devbox" ]; then
        echo "Installing global packages from devbox.json..."
        "$HOME/.local/bin/devbox" global install
    fi
fi

echo ""
echo "Done! Restart your shell or run: source ~/.bashrc"
echo "Then run 'devbox global install' if packages weren't installed."

