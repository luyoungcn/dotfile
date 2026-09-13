# Fish, Fisher, and Tide

Fish is an optional interactive shell in this dotfiles repository. The login
shell remains bash/zsh, and scripts continue to use their shebang (for example,
`#!/usr/bin/env bash`). Fish configuration is loaded only when Fish is used.

## Installation

On Ubuntu/WSL, install Fish and the command-line dependencies with:

```sh
sudo apt update
sudo apt install -y fish fzf curl git
```

Fish is installed on the reference system as version 4.2.1. Install Fisher in a
Fish process with:

```sh
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher'
```

The repository manifest installs Tide v6 and the selected plugins:

```sh
fish -c 'fisher install IlanCosman/tide@v6 jethrokuan/z patrickf1/fzf.fish franciscolourenco/done edc/bass jorgebucaran/nvm.fish'
```

`gazorby/fish-autopair` was not included because Fisher currently reports that
repository as unavailable. Add a maintained fork only after checking its source
and compatibility with Fish 4.x.

Run `./install.sh` to link the repository-managed files, then synchronize the
manifest whenever it changes:

```sh
./install.sh
fish -c 'fisher update'
```

The installer links `config.fish`, files under `conf.d/`, the custom Tide item,
and `fish_plugins` individually. It does not replace Fisher-generated
functions/completions, plugin `conf.d` files, or `fish_variables`.

## Layout

- `config.fish`: small entry point; no prompt initialization is needed because
  Tide owns the prompt after Fisher installs it.
- `conf.d/00_env.fish`: Fish-only paths, WSL gateway detection, and `NVM_DIR`.
- `conf.d/05_rustup.fish`: loads Cargo's Fish environment when present.
- `conf.d/10_aliases.fish`: interactive aliases.
- `conf.d/20_functions.fish`: proxy, Docker SDK, and yazi helpers.
- `conf.d/30_tide.fish`: universal Catppuccin Frappé Tide variables.
- `functions/_tide_item_nvm.fish`: custom Tide item for the active
  `nvm.fish` version.
- `fish_plugins`: Fisher manifest, including Tide v6, z, fzf.fish, done, bass,
  and nvm.fish.

## Tide theme

The prompt uses the Catppuccin Frappé colors already used by
`tmux/colors.conf`. The left prompt is `pwd git newline character`; the right
prompt is `status cmd_duration jobs nvm python time`. Tide v6 calls the
background-job item `jobs` and the Python virtual-environment item `python`.
The repository adds the missing `nvm` item locally.

All Tide settings are written as universal variables in `conf.d/30_tide.fish`,
so a new Fish process receives the same theme without changing the login shell.

## Existing Fish configuration

Do not symlink the entire `~/.config/fish` directory. Keep Fisher's generated
files and `fish_variables` in place. `./install.sh` backs up an existing
`config.fish` or managed module before linking the repository version; review
the timestamped backup if local settings were not already migrated. Add future
customizations as new `conf.d/` modules rather than editing generated plugin
files.

## Verification

```sh
fish --version
fish -c 'type -q fisher; and fisher --version'
fish -c 'tide --version'
fish -c 'fisher list'
fish -c 'string join " " $tide_left_prompt_items'
fish -c 'string join " " $tide_right_prompt_items'
fish -c 'type -q _tide_item_nvm'
```

Start an interactive Fish shell with `fish` to inspect the prompt. `nvm use
<version>` makes the custom nvm segment visible; activating a Python virtual
environment makes the Tide `python` segment visible.
