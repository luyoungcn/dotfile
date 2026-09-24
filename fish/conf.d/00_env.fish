# Keep Fish-only environment setup separate from bash/zsh configuration.
status is-interactive; or return

fish_add_path --global "$HOME/.local/bin" "$HOME/.cargo/bin"

# Homebrew on Apple Silicon does not add itself to Fish's PATH.
test -d /opt/homebrew/bin; and fish_add_path --append --global /opt/homebrew/bin /opt/homebrew/sbin

# Pi's launcher uses its standalone Node.js runtime.
set -l pi_node_bin "$HOME/.local/share/pi-node/current/bin"
test -d "$pi_node_bin"; and fish_add_path --global "$pi_node_bin"

# snap is Ubuntu-specific; only add the directory when it actually exists.
if test -d /snap/bin
    fish_add_path --global /snap/bin
end

set -gx NVM_DIR "$HOME/.nvm"

# Resolve the WSL host gateway lazily for the proxy helpers.
# /proc/version only exists on Linux; the "microsoft" marker identifies WSL.
if test -r /proc/version; and grep -qi microsoft /proc/version
    if type -q ip
        set -l gateway (ip route 2>/dev/null | awk '/default/ {print $3; exit}')
        test -n "$gateway"; and set -gx host_ip $gateway
    end
end
