status is-interactive; or return

# 代理开关：跨平台可用。
#   - WSL：host 指向 Windows 主机网关（通过 ip route 获取）。
#   - macOS/Linux：host 指向本机 127.0.0.1。
# 端口默认 7897，可通过 PROXY_PORT 变量覆盖。
function __proxy_resolve_host
    if test -r /proc/version; and grep -qi microsoft /proc/version
        set -l gateway (ip route 2>/dev/null | awk '/default/ {print $3; exit}')
        if test -z "$gateway"
            echo "Unable to determine the WSL host gateway." >&2
            return 1
        end
        echo $gateway
    else
        echo 127.0.0.1
    end
end

function proxy_on
    if not set -q host_ip
        set -l resolved (__proxy_resolve_host); or return 1
        set -gx host_ip $resolved
    end

    set -l proxy_port 7897
    set -q PROXY_PORT; and set proxy_port $PROXY_PORT

    set -gx http_proxy "http://$host_ip:$proxy_port"
    set -gx https_proxy "http://$host_ip:$proxy_port"
    set -gx all_proxy "socks5://$host_ip:$proxy_port"
    set -gx HTTP_PROXY "http://$host_ip:$proxy_port"
    set -gx HTTPS_PROXY "http://$host_ip:$proxy_port"
    set -gx ALL_PROXY "socks5://$host_ip:$proxy_port"
    echo "Proxy enabled -> $host_ip:$proxy_port"
end

function proxy_off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e ALL_PROXY
    echo "Proxy disabled."
end

# 兼容旧 zsh 时代的命令名 proxy/unproxy
alias proxy proxy_on
alias unproxy proxy_off

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
