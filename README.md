# dotfiles

Personal Linux/WSL development-environment configuration for Neovim, tmux,
zsh, optional interactive Fish, Starship, and i3-related desktop tools.

## Architecture

This repository uses explicit configuration files and manual symbolic links.
`install.sh` is the deployment entry point; it does not use GNU Stow or
chezmoi, and it does not change the login shell.

| Area | Repository entry point | Deployment target | Managed by `install.sh` |
| --- | --- | --- | --- |
| Neovim | `nvim/` | `${XDG_CONFIG_HOME:-~/.config}/nvim` | Yes, directory link |
| tmux | `tmux/tmux.conf` | `${XDG_CONFIG_HOME:-~/.config}/tmux/tmux.conf` | Yes |
| tmux palette | `tmux/colors.conf` | `${XDG_CONFIG_HOME:-~/.config}/tmux/colors.conf` | Yes |
| Fish | `fish/config.fish`, `fish/conf.d/` | `${XDG_CONFIG_HOME:-~/.config}/fish/` | Yes, per-file links |
| Fisher manifest | `fish/fish_plugins` | `${XDG_CONFIG_HOME:-~/.config}/fish/fish_plugins` | Yes |
| Starship | `starship/starship.toml` | `${XDG_CONFIG_HOME:-~/.config}/starship.toml` | Yes |
| zsh | `zsh/zshrc`, `zsh/p10k.zsh` | `~/.zshrc`, `~/.p10k.zsh` | Yes |

The legacy desktop/system files (`i3/`, `rofi/`, `Xresources`, `gtkrc-2.0`,
`onedark.theme`, `dnscrypt-proxy.toml`, and `unbound.conf`) remain in the
repository but are not linked by the current installer. Deploy those files
manually when needed for a specific machine.

## Shell model

zsh (or bash) remains the login shell. Fish is an optional interactive shell;
starting `fish` loads its configuration, but scripts keep using their own
shebang, such as `#!/usr/bin/env bash`. No configuration in this repository
calls `chsh`.

## Prerequisites

The installer assumes `sh`, `git`, and a writable home directory. It installs
TPM but does not install system packages, Neovim, tmux, zsh, Fish, Nerd Fonts,
Oh My Zsh, Powerlevel10k, Starship, or command-line tools.

On Ubuntu/WSL, install a practical baseline with:

```sh
sudo apt update
sudo apt install -y git curl tmux zsh fish fzf ripgrep fd-find
```

Install shell-specific managers and themes as described in:

- [Fish, Fisher, and Tide](fish/README.md)
- [Zsh configuration](zsh/README.md)
- [Starship prompt](starship/README.md)
- [Tmux and TPM](tmux/README.md)
- [Neovim/LazyVim](nvim/README.md)

## Deployment

Clone the repository and run the installer:

```sh
git clone <your-repository-url> ~/Document/dotfile
cd ~/Document/dotfile
./install.sh
```

Existing target files are moved to timestamped sibling backups before a link
is created. Fish is handled per file so Fisher-generated functions,
completions, plugin `conf.d` files, and `fish_variables` remain untouched.

TPM defaults to `${XDG_CONFIG_HOME:-~/.config}/tmux/plugins`. Override its
location before deployment when required:

```sh
TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" ./install.sh
```

The installer does not install Fisher plugins. After installing Fish and
Fisher, synchronize the repository manifest with:

```sh
fish -c 'fisher update'
```

## Component summary

### Neovim

LazyVim is the base distribution managed by `lazy.nvim`. Personal plugin
specifications live in `nvim/lua/plugins/`; Catppuccin Mocha, bufferline,
Noice/Snacks, and the custom lualine statusline are configured there. See the
[Neovim README](nvim/README.md) and the [development guide](nvim/lazyvim-development-guide.md).

### tmux

The standalone `tmux/tmux.conf` owns options, `Ctrl-a` bindings, plugin
declarations, status-bar layout, and pane/window styles. `colors.conf` provides
the Catppuccin Frappé palette. TPM is initialized at the end of the file; the
oh-my-tmux dependency and `tmux.conf.local` have been removed. See
[tmux/README.md](tmux/README.md) for plugin controls and pane zoom behavior.

### Fish

Fish uses Fisher with Tide v6 and a manifest containing `z`, `fzf.fish`, `done`,
`bass`, and `nvm.fish`. The prompt uses Catppuccin Frappé colors to match tmux.
Configuration is split into `config.fish`, numbered `conf.d/` modules, and a
small custom nvm Tide item. See [fish/README.md](fish/README.md).

### zsh and Starship

zsh loads Oh My Zsh plugins and uses Starship as the primary prompt when the
binary is available, with Powerlevel10k retained as a fallback. The zsh proxy,
Docker helpers, and private environment-file behavior are documented in
[zsh/README.md](zsh/README.md). Starship's One Dark prompt is documented in
[starship/README.md](starship/README.md).

## Verification

After deployment, verify links and shell configuration:

```sh
git status --short
sh -n install.sh
tmux -V
fish --version
fish -c 'fisher list'
fish -c 'tide --version'
zsh -n "$HOME/.zshrc"
```

For an interactive check, run `fish`, start tmux, and confirm the Catppuccin
status bar and Tide prompt render with the installed Nerd Font.

## Updating the repository

Edit repository files, rerun `./install.sh` when links need refreshing, and
commit only the component being changed:

```sh
git add nvim tmux fish zsh starship README.md install.sh
git commit
```

Keep generated plugin directories, caches, `fish_variables`, and private
credential files outside Git. Review timestamped backups before removing any
old local configuration.
