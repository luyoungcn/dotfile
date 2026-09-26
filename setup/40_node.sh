#!/bin/sh
# Node.js LTS via the nvm.fish Fisher plugin.
# `nvm` becomes available after 30_fisher.sh installs nvm.fish.
#
# In China nodejs.org can be slow/unreachable. When NVM_MIRROR is not set, the
# step probes nodejs.org and automatically falls back to npmmirror. Force a
# specific mirror with:
#   NVM_MIRROR=https://npmmirror.com/mirrors/node ./bootstrap.sh
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have fish || die "fish is not installed; run 00_system.sh first"
have curl || die "curl is required (run 00_system.sh first)"

# nvm.fish stores versions in nvm_data (~/.local/share/nvm by default).
nvm_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"

if find "$nvm_data" -maxdepth 1 -type d -name 'v*' 2>/dev/null | grep -q .; then
    info "nvm already has Node versions installed under $nvm_data"
else
    # Select the Node download mirror before installing.
    if [ -n "${NVM_MIRROR:-}" ]; then
        fish -c 'set -U nvm_mirror $argv[1]' "$NVM_MIRROR"
    elif ! curl -fsSL --connect-timeout 5 --max-time 15 "https://nodejs.org/dist/index.tab" -o /dev/null; then
        info "nodejs.org unreachable; using npmmirror for Node downloads"
        fish -c 'set -U nvm_mirror https://npmmirror.com/mirrors/node'
    fi

    info "Installing Node.js LTS"
    fish -c 'nvm install lts'
fi

# Always record the default version, even when Node is already installed. This
# lets a re-run repair a machine where Node was installed but the default was
# never set (the activation in nvm.fish reads this universal variable).
fish -c 'set -U nvm_default_version lts'
