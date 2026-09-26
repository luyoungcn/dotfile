#!/bin/sh
# Docker Engine + CLI (+ Compose).
#
# Linux (Ubuntu): follow Docker's official apt-repository steps instead of
# running a remote convenience script — the repo/keyring setup is explicit,
# auditable, and reproducible. Non-Ubuntu Linux falls back to get.docker.com.
# macOS: reuse an existing Docker Desktop/OrbStack install; otherwise install
# colima + Docker CLI + Compose via Homebrew.
#
# In China, download.docker.com is often unreachable. The step auto-falls
# back to the USTC mirror when the official host is unreachable; set
# DOCKER_APT_MIRROR to force a specific base:
#   DOCKER_APT_MIRROR=https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu ./bootstrap.sh
#
# Docker image pulls (registry.docker.io) are handled separately: the step
# auto-falls back to a working public registry mirror, or uses
# DOCKER_REGISTRY_MIRRORS (comma/space separated) when set.
set -eu

. "$(CDPATH= cd "$(dirname "$0")" && pwd)/lib.sh"

have curl || die "curl is required (run 00_system.sh first)"

docker_apt_base=${DOCKER_APT_MIRROR:-https://download.docker.com/linux/ubuntu}
# Only auto-fallback when no explicit mirror was configured.
docker_apt_fallback=""
if [ -z "${DOCKER_APT_MIRROR:-}" ]; then
    docker_apt_fallback="https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu"
fi

install_docker_ubuntu() {
    info "Removing conflicting packages"
    as_root apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true

    info "Installing prerequisites"
    as_root apt-get update
    as_root apt-get install -y ca-certificates curl gnupg

    info "Adding Docker's official apt repository key"
    as_root install -m 0755 -d /etc/apt/keyrings

    key=$(mktemp)
    if curl -fsSL --connect-timeout 5 --max-time 15 "$docker_apt_base/gpg" -o "$key"; then
        :
    elif [ -n "$docker_apt_fallback" ]; then
        info "$docker_apt_base unreachable; falling back to $docker_apt_fallback"
        docker_apt_base=$docker_apt_fallback
        curl -fsSL --connect-timeout 5 --max-time 15 "$docker_apt_base/gpg" -o "$key" ||
            die "Failed to download Docker GPG key from $docker_apt_base"
    else
        die "Failed to download Docker GPG key from $docker_apt_base"
    fi
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

# A registry answers /v2/ with 401 (auth required) or 200 when reachable.
registry_reachable() {
    code=$(curl -sL -o /dev/null -w '%{http_code}' --connect-timeout 4 --max-time 8 "$1/v2/")
    [ "$code" = "401" ] || [ "$code" = "200" ]
}

# Merge registry mirrors into /etc/docker/daemon.json without clobbering it.
write_registry_mirrors() {
    have jq || die "jq is required (run 00_system.sh first)"

    mirrors_json=$(printf '%s\n' "$@" | jq -Rn '[inputs]')

    as_root install -m 0755 -d /etc/docker
    if [ -f /etc/docker/daemon.json ]; then
        merged=$(jq --argjson m "$mirrors_json" '. + {"registry-mirrors": $m}' /etc/docker/daemon.json) ||
            die "Invalid existing /etc/docker/daemon.json"
    else
        merged=$(printf '%s' "$mirrors_json" | jq '{ "registry-mirrors": . }')
    fi
    printf '%s\n' "$merged" | as_root tee /etc/docker/daemon.json >/dev/null
    info "Wrote registry mirrors to /etc/docker/daemon.json"
}

restart_docker() {
    if as_root systemctl restart docker 2>/dev/null; then
        info "Restarted Docker daemon"
    elif as_root service docker restart 2>/dev/null; then
        info "Restarted Docker daemon"
    else
        info "Restart Docker manually to apply registry mirrors"
    fi
}

configure_registry_mirrors() {
    mirrors=${DOCKER_REGISTRY_MIRRORS:-}

    # Auto-detect only when no mirror was explicitly configured.
    if [ -z "$mirrors" ] && ! registry_reachable "https://registry.docker.io"; then
        # Best-effort public mirrors. Kept short and overridable because these
        # endpoints change often in China.
        for candidate in \
            https://docker.m.daocloud.io \
            https://docker.1ms.run \
            https://dockerproxy.net \
            https://hub.rat.dev
        do
            if registry_reachable "$candidate"; then
                mirrors=$candidate
                break
            fi
        done
    fi

    if [ -z "$mirrors" ]; then
        if ! registry_reachable "https://registry.docker.io"; then
            info "Docker Hub is unreachable and no working public mirror was found."
            info "For China, get a free Aliyun accelerator URL, then re-run with:"
            info "  DOCKER_REGISTRY_MIRRORS=https://<your-id>.mirror.aliyuncs.com ./bootstrap.sh"
        fi
        return 0
    fi

    # Accept comma- or space-separated mirrors.
    write_registry_mirrors $(printf '%s' "$mirrors" | tr ',' ' ')
    restart_docker
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

        configure_registry_mirrors

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
