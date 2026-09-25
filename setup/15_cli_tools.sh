#!/bin/sh
# Optional CLI tools referenced by the fish aliases and functions:
#   eza       -> alias eza
#   lazygit   -> alias lg
#   yazi + ya -> function y
# All are installed from official GitHub releases into ~/.local/bin.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have curl || die "curl is required (run 00_system.sh first)"
have jq || die "jq is required (run 00_system.sh first)"

triple=$(target_triple)

# eza — GitHub no longer ships macOS binaries, so use Homebrew there.
if have eza; then
    info "eza already installed at $(command -v eza)"
else
    case "$(os_name)" in
        linux) install_github_binaries eza-community/eza "eza_${triple}\.tar\.gz" '/eza$' ;;
        macos) install_pkgs eza ;;
        *) die "Unsupported OS: $(uname -s)" ;;
    esac
fi

# lazygit — release assets use lowercase darwin/linux.
case "$(os_name)" in
    macos) lg_os=darwin ;;
    linux) lg_os=linux ;;
    *) die "Unsupported OS: $(uname -s)" ;;
esac
if have lazygit; then
    info "lazygit already installed at $(command -v lazygit)"
else
    install_github_binaries jesseduffield/lazygit "lazygit_.*_${lg_os}_$(arch_name)\.tar\.gz" '/lazygit$'
fi

# yazi + ya
if have yazi; then
    info "yazi already installed at $(command -v yazi)"
else
    install_github_binaries sxyazi/yazi "yazi-${triple}\.zip" '/(yazi|ya)$'
fi
