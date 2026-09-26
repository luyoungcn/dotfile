#!/bin/sh
# Docker Engine + CLI (+ Compose).
#
# Linux (Ubuntu): follow Docker's official apt-repository steps instead of
# running a remote convenience script — the repo/keyring setup is explicit,
# auditable, and reproducible. Non-Ubuntu Linux falls back to get.docker.com.
# macOS: reuse an existing Docker Desktop/OrbStack install; otherwise install
# colima + Docker CLI + Compose via Homebrew.
#
# In China, download.docker.com is often unreachable; override the repo base:
#   DOCKER_APT_MIRROR=https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu ./bootstrap.sh
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have curl || die "curl is required (run 00_system.sh first)"

docker_apt_base=${DOCKER_APT_MIRROR:-https://download.docker.com/linux/ubuntu}

install_docker_ubuntu() {
    info "Removing conflicting packages"
    as_root apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true

    info "Installing prerequisites"
    as_root apt-get update
    as_root apt-get install -y ca-certificates curl gnupg

    info "Adding Docker's official apt repository key"
    as_root install -m 0755 -d /etc/apt/keyrings

    key=$(mktemp)
    curl -fsSL "$docker_apt_base/gpg" -o "$key" || die "Failed to download Docker GPG key"
    gpg --dearmor -o "$key.gpg" < "$key" || die "Failed to dearmor Docker GPG key"
    as_root install -m 0644 "$key.gpg" /etc/apt/keyrings/docker.gpg
    rm -f "$key" "$key.gpg"

    info "Adding Docker's official apt repository"
    arch=$(dpkg --print-architecture)
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    printf '%s\n' "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] $docker_apt_base $codename stable" |
        as_root tee /etc/apt/sources.list.d/docker.list >/dev/null

    info "Installing Docker Engine + CLI + Compose plugin"
    as_root apt-get update
    as_root apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_docker_getdocker() {
    info "Installing Docker Engine via get.docker.com (non-Ubuntu fallback)"
    tmp=$(mktemp)
    curl -fsSL https://get.docker.com -o "$tmp" || die "Failed to download get.docker.com"
    as_root sh "$tmp"
    rm -f "$tmp"
}

case "$(os_name)" in
    linux)
        if have docker; then
            info "Docker already installed: $(docker --version)"
        else
            if [ -r /etc/os-release ] && [ "$(. /etc/os-release && echo "${ID:-}")" = ubuntu ]; then
                install_docker_ubuntu
            else
                install_docker_getdocker
            fi
        fi

        # Non-root access via the docker group (applies after re-login).
        if id -Gn 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
            info "User already in the docker group"
        else
            as_root usermod -aG docker "$(id -un)"
            info "Added $(id -un) to the docker group (log out and back in to apply)"
        fi

        # WSL2 without systemd needs the daemon started by hand.
        if test -r /proc/version && grep -qi microsoft /proc/version; then
            info "WSL detected: run 'sudo service docker start' if systemd is disabled"
        fi
        ;;
    macos)
        if have docker; then
            info "Docker already installed: $(docker --version)"
        else
            install_pkgs colima docker docker-compose
            brew_bin=$(find_brew)
            colima_bin="$(dirname "$brew_bin")/colima"
            info "Starting colima (first run provisions a VM)"
            "$colima_bin" start
        fi
        ;;
    *)
        die "Unsupported OS: $(uname -s)"
        ;;
esac
