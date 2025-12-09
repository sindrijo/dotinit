# dotinit

Bootstrap scripts for setting up new machines.

## Available Scripts

### dotfiles.sh

Sets up dotfiles on a new system (optimized for WSL).

Execute:

```bash
curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash
```

Dry run (see what would happen):

```bash
curl -fsSL https://raw.githubusercontent.com/sindrijo/dotinit/refs/heads/main/dotfiles.sh | bash -s -- -n
```

**What it does:**
- Configures git to use Windows credential manager (WSL)
- Clones dotfiles as a bare repo to `~/.dotfiles`
- Backs up any conflicting files
- Sets up the `dotfiles` alias

