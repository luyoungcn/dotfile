#!/bin/sh
# Latest Neovim from the official GitHub release. apt's neovim is often too
# old for LazyVim, so install a self-contained build under ~/.local/opt/nvim
# and link bin/nvim into ~/.local/bin (already on fish's PATH).
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have curl || die "curl is required (run 00_system.sh first)"
have jq || die "jq is required (run 00_system.sh first)"

if have nvim; then
    info "Neovim already installed at $(command -v nvim)"
    exit 0
fi

case "$(os_name)" in
    linux) nvim_os=linux ;;
    macos) nvim_os=macos ;;
    *) die "Unsupported OS: $(uname -s)" ;;
esac

asset_url=$(gh_latest_asset neovim/neovim "nvim-${nvim_os}-$(arch_name)\.tar\.gz")
[ -n "$asset_url" ] || die "No Neovim release asset for $nvim_os/$(arch_name)"

tmp=$(mktemp -d)
info "Downloading $asset_url"
curl -fsSL "$asset_url" -o "$tmp/nvim.tar.gz" || die "Download failed: $asset_url"
tar -xzf "$tmp/nvim.tar.gz" -C "$tmp" || die "Failed to extract $asset_url"

install_dir="$HOME/.local/opt/nvim"
mkdir -p "$HOME/.local/opt"
rm -rf "$install_dir"
mv "$tmp"/nvim-* "$install_dir"

mkdir -p "$HOME/.local/bin"
ln -sf "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
info "Installed nvim -> $HOME/.local/bin/nvim"

rm -rf "$tmp"
