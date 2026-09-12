#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
tmux_plugin_dir=${TMUX_PLUGIN_MANAGER_PATH:-"$config_dir/tmux/plugins"}
timestamp=$(date +%Y%m%d-%H%M%S)

backup_target() {
  target=$1
  backup="${target}.backup-${timestamp}"

  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="${backup}-1"
  done

  mv -- "$target" "$backup"
  printf 'Backed up %s to %s\n' "$target" "$backup"
}

link_config() {
  source_path=$1
  target_path=$2

  mkdir -p -- "$(dirname -- "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink -f -- "$target_path")" = "$(readlink -f -- "$source_path")" ]; then
    printf 'Already linked: %s\n' "$target_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_target "$target_path"
  fi

  ln -s -- "$source_path" "$target_path"
  printf 'Linked %s -> %s\n' "$target_path" "$source_path"
}

install_tpm() {
  tpm_dir="$tmux_plugin_dir/tpm"

  if [ -d "$tpm_dir/.git" ]; then
    printf 'TPM already installed: %s\n' "$tpm_dir"
    return
  fi

  # Do not overwrite an unrelated directory.  Moving it to a timestamped
  # backup keeps the install reversible and follows the link backup policy.
  if [ -e "$tpm_dir" ] || [ -L "$tpm_dir" ]; then
    backup_target "$tpm_dir"
  fi

  mkdir -p -- "$tmux_plugin_dir"
  git clone --depth 1 https://github.com/tmux-plugins/tpm.git "$tpm_dir"
  printf 'Installed TPM to %s\n' "$tpm_dir"
}

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'Error: git is required to install TPM.' >&2
  exit 1
fi

install_tpm

link_config "$repo_dir/nvim" "$config_dir/nvim"
link_config "$repo_dir/tmux/tmux.conf" "$config_dir/tmux/tmux.conf"
link_config "$repo_dir/tmux/colors.conf" "$config_dir/tmux/colors.conf"
link_config "$repo_dir/starship/starship.toml" "$config_dir/starship.toml"
link_config "$repo_dir/zsh/zshrc" "$HOME/.zshrc"
link_config "$repo_dir/zsh/p10k.zsh" "$HOME/.p10k.zsh"

printf 'Dotfiles installed.\n'
printf 'TPM plugins:           %s\n' "$tmux_plugin_dir"
printf 'Reload tmux with:  tmux source-file %s\n' "$config_dir/tmux/tmux.conf"
printf 'Reload zsh with:   exec zsh\n'
