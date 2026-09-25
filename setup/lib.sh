# setup/lib.sh — shared helpers for the numbered setup steps.
# Source this file from each setup/NN_*.sh; it is not a step itself.

os_name() {
    case "$(uname -s)" in
        Linux*)  echo linux ;;
        Darwin*) echo macos ;;
        *)       echo unknown ;;
    esac
}

arch_name() {
    case "$(uname -m)" in
        x86_64|amd64)  echo x86_64 ;;
        aarch64|arm64) echo arm64 ;;
        *)             echo "$(uname -m)" ;;
    esac
}

have() {
    command -v "$1" >/dev/null 2>&1
}

info() {
    printf '  [setup] %s\n' "$*"
}

die() {
    printf '  [setup] ERROR: %s\n' "$*" >&2
    exit 1
}

# Run a command via sudo only when not already root (containers often run as
# root and may not even have sudo installed).
as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Install a list of packages using the platform package manager.
install_pkgs() {
    case "$(os_name)" in
        linux)
            as_root apt-get update
            as_root apt-get install -y "$@"
            ;;
        macos)
            brew_bin=""
            if have brew; then
                brew_bin="$(command -v brew)"
            else
                # Homebrew may be installed but not yet on this shell's PATH.
                for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                    [ -x "$candidate" ] && brew_bin="$candidate" && break
                done
            fi
            if [ -z "$brew_bin" ]; then
                info "Installing Homebrew"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                    [ -x "$candidate" ] && brew_bin="$candidate" && break
                done
            fi
            [ -n "$brew_bin" ] || die "Homebrew did not install correctly"
            "$brew_bin" install "$@"
            ;;
        *)
            die "Unsupported OS for package installation: $(uname -s)"
            ;;
    esac
}

# Rust-style target triple used by eza/yazi release assets.
target_triple() {
    case "$(os_name) $(arch_name)" in
        "linux x86_64") echo "x86_64-unknown-linux-gnu" ;;
        "linux arm64")  echo "aarch64-unknown-linux-gnu" ;;
        "macos x86_64") echo "x86_64-apple-darwin" ;;
        "macos arm64")  echo "aarch64-apple-darwin" ;;
        *) die "Unsupported target: $(os_name)/$(arch_name)" ;;
    esac
}

# Print the browser_download_url of the first GitHub release asset whose name
# matches <asset_grep> (a regex handed to jq's test()).
gh_latest_asset() {
    repo=$1
    asset_grep=$2
    have curl || die "curl is required"
    have jq || die "jq is required (run 00_system.sh first)"

    release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest") ||
        die "Failed to query GitHub releases for $repo"

    printf '%s\n' "$release_json" |
        jq -r --arg pat "$asset_grep" \
            '.assets[] | select(.name | test($pat)) | .browser_download_url' |
        sed -n '1p'
}

# Download the latest GitHub release asset matching <asset_grep>, extract it
# (.tar.gz or .zip), and install every extracted file matching <bin_grep>
# (matched against the full path) into ~/.local/bin.
install_github_binaries() {
    repo=$1 asset_grep=$2 bin_grep=$3

    asset_url=$(gh_latest_asset "$repo" "$asset_grep")
    [ -n "$asset_url" ] || die "No release asset matches '$asset_grep' for $repo"

    tmp=$(mktemp -d)
    archive="$tmp/asset"
    info "Downloading $asset_url"
    curl -fsSL "$asset_url" -o "$archive" || die "Download failed: $asset_url"

    case "$asset_url" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$tmp" || die "Failed to extract $archive"
            ;;
        *.zip)
            have unzip || die "unzip is required (run 00_system.sh first)"
            unzip -q "$archive" -d "$tmp" || die "Failed to extract $archive"
            ;;
        *)
            die "Unsupported archive format: $asset_url"
            ;;
    esac

    list=$(mktemp)
    find "$tmp" -type f | grep -E "$bin_grep" > "$list" || true
    if ! grep -q . "$list"; then
        rm -rf "$tmp"; rm -f "$list"
        die "No binary matching '$bin_grep' found in $asset_url"
    fi

    mkdir -p "$HOME/.local/bin"
    while IFS= read -r file; do
        install -m 755 "$file" "$HOME/.local/bin/$(basename "$file")"
        info "Installed $(basename "$file") -> $HOME/.local/bin"
    done < "$list"

    rm -rf "$tmp"
    rm -f "$list"
}
