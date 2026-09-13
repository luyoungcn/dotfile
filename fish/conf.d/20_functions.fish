status is-interactive; or return

function proxy_on
    if not set -q host_ip
        set -l gateway (ip route 2>/dev/null | awk '/default/ {print $3; exit}')
        if test -z "$gateway"
            echo "Unable to determine the WSL host gateway." >&2
            return 1
        end
        set -gx host_ip $gateway
    end

    set -gx http_proxy "http://$host_ip:7897"
    set -gx https_proxy "http://$host_ip:7897"
    set -gx all_proxy "socks5://$host_ip:7897"
    echo "Proxy environment variables set pointing to Windows host ($host_ip:7897)."
end

function proxy_off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    echo "Proxy environment variables removed."
end

function bst_sdk_25.2.0
    docker start c1200_evkit_docker_sdk-v25.2.0; and docker exec -it -u root -w /workspace/host_folder c1200_evkit_docker_sdk-v25.2.0 bash
end

function bst_sdk_2.3.0.4
    docker start a1000b-sdk-fad-2.3.0.4; and docker exec -it -u root -w /home a1000b-sdk-fad-2.3.0.4 bash
end

function hanhai-sdk-manager-a20000-25
    docker start hanhai-sdk-manager-a2000-25; and docker exec -it -u root -w /home/share_mount hanhai-sdk-manager-a2000-25 /bin/bash
end

function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
