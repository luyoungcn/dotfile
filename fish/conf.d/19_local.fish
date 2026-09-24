# 加载机器私有配置（不提交）。与 zsh 时代的 ~/.zshenv.local 同角色。
# 把你的私密环境变量放在 ~/.config/fish/fish.local，由本模块在启动时 source。
if test -f "$HOME/.config/fish/fish.local"
    source "$HOME/.config/fish/fish.local"
end
