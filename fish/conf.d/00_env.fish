# Keep Fish-only environment setup separate from bash/zsh configuration.
status is-interactive; or return

fish_add_path --global "$HOME/.local/bin" /snap/bin "$HOME/.cargo/bin"

set -gx NVM_DIR "$HOME/.nvm"

# Resolve the WSL host gateway lazily for the proxy helpers.
if type -q ip
    set -l gateway (ip route 2>/dev/null | awk '/default/ {print $3; exit}')
    test -n "$gateway"; and set -gx host_ip $gateway
end
