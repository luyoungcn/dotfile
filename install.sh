#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
tmux_data_dir=${XDG_DATA_HOME:-"$HOME/.local/share"}/tmux
oh_my_tmux_dir="$tmux_data_dir/oh-my-tmux"
oh_my_tmux_ref=af33f07134b76134acca9d01eacbdecca9c9cda6
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

if [ ! -d "$oh_my_tmux_dir/.git" ]; then
  mkdir -p -- "$tmux_data_dir"
  git clone https://github.com/gpakosz/.tmux.git "$oh_my_tmux_dir"
fi

if ! git -C "$oh_my_tmux_dir" cat-file -e "${oh_my_tmux_ref}^{commit}" 2>/dev/null; then
  git -C "$oh_my_tmux_dir" fetch --quiet origin "$oh_my_tmux_ref"
fi
git -C "$oh_my_tmux_dir" checkout --quiet --detach "$oh_my_tmux_ref"

link_config "$repo_dir/nvim" "$config_dir/nvim"
link_config "$oh_my_tmux_dir/.tmux.conf" "$config_dir/tmux/tmux.conf"
link_config "$repo_dir/tmux/tmux.conf.local" "$config_dir/tmux/tmux.conf.local"
link_config "$repo_dir/zsh/zshrc" "$HOME/.zshrc"
link_config "$repo_dir/zsh/p10k.zsh" "$HOME/.p10k.zsh"

printf 'Dotfiles installed.\n'
printf 'Reload tmux with:  tmux source-file %s\n' "$config_dir/tmux/tmux.conf"
printf 'Reload zsh with:   exec zsh\n'
