# Neovim / LazyVim

This directory is the repository-managed Neovim configuration. It is based on
[LazyVim](https://github.com/LazyVim/LazyVim) and uses `lazy.nvim` to resolve
plugins on first launch. The repository is linked as a whole to
`${XDG_CONFIG_HOME:-~/.config}/nvim` by `install.sh`.

## Configuration boundaries

- `init.lua`: loads `config.lazy`.
- `lua/config/`: editor options, keymaps, autocmds, and lazy.nvim bootstrap.
- `lua/plugins/`: personal plugin specifications and UI overrides.
- `lazyvim.json`: enabled LazyVim extras.
- `lazy-lock.json`: reproducible plugin revisions; update it intentionally
  through `:Lazy` rather than editing it by hand.

The current UI uses Catppuccin Mocha, bufferline, Snacks/Noice notifications,
and a custom Catppuccin-aligned lualine statusline. See
[`lazyvim-development-guide.md`](lazyvim-development-guide.md) for the longer
installation, workflow, and troubleshooting guide.

## Prerequisites

Install Neovim, Git, a C compiler, Nerd Fonts, ripgrep, and fd. On Ubuntu/Debian:

```sh
sudo apt install -y neovim git build-essential ripgrep fd-find
```

Run `./install.sh` from the repository root, then start `nvim`. The first start
downloads plugins; use `:Lazy` and `:checkhealth` to inspect the result.

Upstream LazyVim changes should be reviewed before merging. Do not edit the
LazyVim installation directory directly; keep personal changes under
`lua/config/` and `lua/plugins/`.
