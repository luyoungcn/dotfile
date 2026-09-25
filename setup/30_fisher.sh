#!/bin/sh
# Fisher plugin manager plus the plugins declared in fish/fish_plugins
# (z, fzf.fish, done, bass, nvm.fish). Must run after 20_deploy.sh because
# `fisher update` reads the linked ~/.config/fish/fish_plugins.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have fish || die "fish is not installed; run 00_system.sh first"

if fish -c 'type -q fisher' 2>/dev/null; then
    info "Fisher already installed"
else
    info "Installing Fisher"
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher'
fi

info "Synchronizing plugins from fish_plugins"
fish -c 'fisher update'
