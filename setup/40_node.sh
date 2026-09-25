#!/bin/sh
# Node.js LTS via the nvm.fish Fisher plugin.
# `nvm` becomes available after 30_fisher.sh installs nvm.fish.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have fish || die "fish is not installed; run 00_system.sh first"

# nvm.fish stores versions in nvm_data (~/.local/share/nvm by default).
nvm_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"

if find "$nvm_data" -maxdepth 1 -type d -name 'v*' 2>/dev/null | grep -q .; then
    info "nvm already has Node versions installed under $nvm_data"
else
    info "Installing Node.js LTS (downloads from nodejs.org)"
    fish -c 'nvm install lts'
    fish -c 'set -U nvm_default_version lts'
fi
