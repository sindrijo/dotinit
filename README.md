# dotinit

Bootstrap scripts for setting up new machines.

## Available Scripts

### dotfiles.sh

Sets up dotfiles on a new system (optimized for WSL).

Execute:

```bash
curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash
```

Dry run:

```bash
curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash -s -- --dryrun
```

**What it does:**
- Configures git to use Windows credential manager (WSL)
- Clones [dotfiles](https://github.com/sindrijo/dotfiles) as a bare repo to `~/.dotfiles`
- Backs up any conflicting files to `~/.dotfiles-backup`
- Installs Devbox and global packages

### dotfiles-undo.sh

Completely reverts to the original system state.

```bash
./dotfiles-undo.sh
```

**What it does:**
- Removes all files from the dotfiles repo
- Restores original backed-up files
- Removes `~/.dotfiles` and `~/.dotfiles-backup`

### dotfiles-reset.sh

Quick teardown for development/testing.

```bash
./dotfiles-reset.sh
```

**What it does:**
- Removes `~/.dotfiles` bare repo
- Removes `~/.dotfiles-backup`
- Keeps dotfiles in place (for re-testing setup)
