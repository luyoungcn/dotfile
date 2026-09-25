#!/bin/sh
# One-shot development environment bootstrap for a fresh machine.
#
# Runs every numbered step in setup/ in order and stops on the first failure.
# Each step is idempotent, so re-running the whole script is safe. Add new
# tools by dropping a new setup/NN_name.sh file — no edits here are required.
#
# Numbering convention:
#   NN < 20  runs before dotfile deployment (system packages, extra CLIs)
#   NN = 20  deploys the dotfiles (runs install.sh)
#   NN > 20  runs after deployment (shell managers that read the linked config)
set -eu

repo_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)

printf '%s\n' "==> Bootstrapping development environment from $repo_dir"

for step in "$repo_dir"/setup/[0-9][0-9]_*.sh; do
    [ -e "$step" ] || continue
    printf '\n%s\n' "==> Running $(basename "$step")"
    sh "$step"
done

printf '\n%s\n' '==> Bootstrap complete.'
printf '%s\n' 'Start an interactive shell with:  exec fish'
printf '%s\n' 'Then verify with:  node -v; npm -v; fisher list; starship --version'
