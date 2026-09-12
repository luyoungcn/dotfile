# dotfiles

Personal Neovim, tmux, and zsh configuration.

## Layout

- `nvim/`: LazyVim configuration, imported with its original Git history.
- `tmux/tmux.conf`: standalone tmux settings, key bindings, plugin declarations,
  and the status bar layout.
- `tmux/colors.conf`: Catppuccin Frappe palette variables consumed by tmux.
- `starship/starship.toml`: One Dark, two-line Starship prompt configuration.
- `zsh/zshrc`: zsh configuration (Oh My Zsh + plugins + aliases + proxy).
- `zsh/p10k.zsh`: Powerlevel10k theme configuration.
- `install.sh`: idempotent installer for configuration symlinks, TPM, and zsh.

See [`zsh/README.md`](zsh/README.md) for zsh dependency installation.
See [`starship/README.md`](starship/README.md) for prompt design and rollout.
See [`nvim/README.md`](nvim/README.md) for Neovim setup details.
See [`tmux/README.md`](tmux/README.md) for TPM installation and plugin usage.

## Install

```sh
git clone <your-repository-url> ~/Document/dotfile
cd ~/Document/dotfile
./install.sh
```

Existing configurations are moved to timestamped sibling backup paths before a
link is created. The installer does not install Neovim, tmux, Nerd Fonts, or
other system packages. It does install TPM (the tmux plugin manager) under
`$XDG_CONFIG_HOME/tmux/plugins` by default. Set
`TMUX_PLUGIN_MANAGER_PATH` before running the installer to use another
directory, such as `~/.tmux/plugins`.

## Tmux Architecture

The tmux setup is standalone: `tmux.conf` is the entry point and sources
`colors.conf` from the same XDG configuration directory. Its status bar follows
the tmux/Neovim-oriented layout and palette direction of
[`naivecynics/primary-tmux`](https://github.com/naivecynics/primary-tmux), while
the base options and key bindings are maintained for this configuration.

TPM is the only tmux bootstrap dependency. `install.sh` installs it under
`$XDG_CONFIG_HOME/tmux/plugins` by default and the plugin declarations remain in
`tmux/tmux.conf`.

## Tmux Plugin Manager

TPM requires tmux, Git, and Bash. `./install.sh` clones TPM and the
configuration enables `tmux-sensible` as the first plugin. The standalone
configuration invokes TPM at the end of `tmux/tmux.conf`.

Start or reload tmux after installation:

```sh
tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
```

Plugin management uses the configured tmux prefix (`Ctrl-a`):

- `prefix + I`: install newly declared plugins and refresh tmux.
- `prefix + u`: update TPM and all installed plugins.
- `prefix + Alt-u`: remove plugins no longer declared.

To add a plugin, edit [`tmux/tmux.conf`](tmux/tmux.conf) and add
`set -g @plugin 'owner/repository'`, reload the configuration, then press
`prefix + I`. Remove or comment the declaration and press `prefix + Alt-u` to
uninstall it. Plugins are stored in the directory shown by
`TMUX_PLUGIN_MANAGER_PATH` (or `$XDG_CONFIG_HOME/tmux/plugins` by default).

## Update

Edit files through either their repository paths or the links under
`~/.config`, then commit normally:

```sh
git add nvim tmux zsh starship
git commit
```

The LazyVim Starter remote is recorded as `lazyvim-upstream`. Fetching it is
safe, but upstream changes should be reviewed before being merged.
