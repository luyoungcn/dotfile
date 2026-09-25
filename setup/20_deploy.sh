#!/bin/sh
# Deploy the dotfiles: create the symlinks and install TPM. This is the
# original install.sh, kept as a dedicated step so the numbering stays clean.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

info "Deploying dotfiles"
sh "$root/install.sh"
