#!/bin/bash
set -euo pipefail

# Bootstrap dotfiles on a new system (optimized for WSL)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash -s -- -n

DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: dotfiles.sh [-n|--dry-run] [-h|--help]"
            echo ""
            echo "Options:"
            echo "  -n, --dry-run  Show what would be done without making changes"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE - No changes will be made."
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

# Ensure remote is configured (git clone should set this, but be explicit)
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] dotfiles remote set-url origin $DOTFILES_REPO"
else
    dotfiles remote set-url origin "$DOTFILES_REPO"
fi

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
    echo "[DRY RUN] dotfiles config --local push.autoSetupRemote true"
    echo "[DRY RUN] dotfiles branch --set-upstream-to=origin/main main"
else
    dotfiles config --local status.showUntrackedFiles no
    dotfiles config --local push.autoSetupRemote true
    dotfiles branch --set-upstream-to=origin/main main
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

