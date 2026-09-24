status is-interactive; or return

# WSL 代理开关：仅在 WSL 环境下定义，避免在其他平台产生无效命令。
if test -r /proc/version; and grep -qi microsoft /proc/version
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
end

# 通用 Docker 容器进入工具（迁移自 zsh/zshrc 的 denter）。
# 用法：denter <容器名> [工作目录=/workspace] [用户=root] [shell=/bin/bash]
function denter --description '启动并进入 Docker 容器'
    set -l container_name "$argv[1]"
    if test -z "$container_name"
        echo "Error: Container name is required." >&2
        return 1
    end

    set -l work_dir /workspace
    set -l user root
    set -l shell_bin /bin/bash
    set -q argv[2]; and set work_dir "$argv[2]"
    set -q argv[3]; and set user "$argv[3]"
    set -q argv[4]; and set shell_bin "$argv[4]"

    docker ps -a --format '{{.Names}}' | string match -q "$container_name"
    or begin
        echo "Error: Container '$container_name' does not exist." >&2
        return 1
    end

    if test (docker inspect -f '{{.State.Running}}' "$container_name" 2>/dev/null) != true
        echo "Starting container '$container_name'..."
        docker start "$container_name" >/dev/null; or return 1
    end

    echo "Entering '$container_name' as '$user' at '$work_dir'..."
    docker exec -it -u "$user" -w "$work_dir" "$container_name" "$shell_bin"
end

complete -c denter -f -a '(docker ps -a --format "{{.Names}}")'

# SDK 快捷入口：薄封装 denter（迁移自 zsh/zshrc 的别名）。
function bst_sdk_25.2.0
    denter c1200_evkit_docker_sdk-v25.2.0 /workspace/host_folder
end

function bst_sdk_2.3.0.4
    denter a1000b-sdk-fad-2.3.0.4 /home
end

function hanhai-sdk-2000
    denter hanhai-sdk-manager-a2000-25 /home/share_mount
end

function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    command rm -f "$tmp"
end
