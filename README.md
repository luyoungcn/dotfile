# dotfiles

Personal Neovim, tmux, and zsh configuration.

## Layout

- `nvim/`: LazyVim configuration, imported with its original Git history.
- `tmux/tmux.conf.local`: personal overrides for oh-my-tmux.
- `zsh/zshrc`: zsh configuration (Oh My Zsh + plugins + aliases + proxy).
- `zsh/p10k.zsh`: Powerlevel10k theme configuration.
- `install.sh`: idempotent installer for configuration symlinks, oh-my-tmux, and zsh.

See [`zsh/README.md`](zsh/README.md) for zsh dependency installation.
See [`nvim/README.md`](nvim/README.md) for Neovim setup details.

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
git add nvim tmux zsh
git commit
```

The LazyVim Starter remote is recorded as `lazyvim-upstream`. Fetching it is
safe, but upstream changes should be reviewed before being merged.

