#!/bin/sh
# Starship prompt binary. Installs to ~/.local/bin, which fish puts on PATH
# via conf.d/00_env.fish.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have curl || die "curl is not installed; run 00_system.sh first"

if have starship; then
    info "Starship already installed: $(starship --version)"
else
    info "Installing Starship to $HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi
