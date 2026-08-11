# dotfiles

Personal Neovim and tmux configuration.

## Layout

- `nvim/`: LazyVim configuration, imported with its original Git history.
- `tmux/tmux.conf.local`: personal overrides for oh-my-tmux.
- `install.sh`: idempotent installer for configuration symlinks and oh-my-tmux.

The repository deliberately does not manage zsh yet.

## Install

```sh
git clone <your-repository-url> ~/Document/dotfile
cd ~/Document/dotfile
./install.sh
```

Existing configurations are moved to timestamped sibling backup paths before a
link is created. The installer does not install Neovim, tmux, Nerd Fonts, or
other system packages.

## Update

Edit files through either their repository paths or the links under
`~/.config`, then commit normally:

```sh
git add nvim tmux
git commit
```

The LazyVim Starter remote is recorded as `lazyvim-upstream`. Fetching it is
safe, but upstream changes should be reviewed before being merged.

