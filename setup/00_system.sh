#!/bin/sh
# Base toolchain every later step depends on.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

info "OS: $(uname -s) / $(arch_name)"

case "$(os_name)" in
    linux)
        install_pkgs \
            git curl ca-certificates unzip jq \
            fish tmux fzf ripgrep fd-find \
            build-essential

        # Debian/Ubuntu ship fd-find as `fdfind`; tools expect `fd`.
        if have fdfind && ! have fd; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
            info "Linked fd -> fdfind in $HOME/.local/bin"
        fi
        ;;
    macos)
        install_pkgs git curl unzip jq fish tmux fzf ripgrep fd
        ;;
    *)
        die "Unsupported OS: $(uname -s)"
        ;;
esac
