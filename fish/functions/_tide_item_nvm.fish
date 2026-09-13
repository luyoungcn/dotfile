# Tide v6 has no built-in nvm item; show the active nvm.fish version.
function _tide_item_nvm
    if set -q nvm_current_version
        _tide_print_item nvm $tide_nvm_icon' ' $nvm_current_version
    end
end
