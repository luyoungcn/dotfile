# Zsh Configuration

本目录包含 zsh 配置文件，通过 `install.sh` 以符号链接方式部署到 `~/.zshrc` 和 `~/.p10k.zsh`。
本仓库不会自动修改默认登录 Shell；bash 用户可以继续使用 bash，zsh 用户无需再次执行 `chsh`。
Starship 配置位于 [`../starship/README.md`](../starship/README.md)，并链接到
`${XDG_CONFIG_HOME:-~/.config}/starship.toml`。

## 文件说明

| 文件 | 部署位置 | 说明 |
|------|---------|------|
| `zshrc` | `~/.zshrc` | zsh 主配置文件（Oh My Zsh + 插件 + 别名 + 代理函数 + Starship/P10k 回退） |
| `p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k 主题配置文件 |

## 依赖安装

在使用本配置前，需要先安装以下依赖。

### 1. 安装 zsh

```bash
# 更新软件源
sudo apt update && sudo apt upgrade -y

# 安装 zsh git curl
sudo apt install zsh git curl -y
```

如果你确实希望把 zsh 设为默认登录 Shell（这是可选操作，**不要使用 sudo**），然后注销并重新登录：

```bash
chsh -s /bin/zsh

# 如果无效，尝试这个命令
chsh -s $(which zsh)
```

### 2. 安装 Oh My Zsh

| 方式 | 命令 |
|------|------|
| curl | `sh -c "$(curl -fsSL https://install.ohmyz.sh/)"` |
| wget | `sh -c "$(wget -O- https://install.ohmyz.sh/)"` |
| fetch | `sh -c "$(fetch -o - https://install.ohmyz.sh/)"` |
| 国内 curl 镜像 | `sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)"` |
| 国内 wget 镜像 | `sh -c "$(wget -O- https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)"` |

更新 Oh My Zsh：

```bash
upgrade_oh_my_zsh
```

卸载：

```bash
uninstall_oh_my_zsh
```

### 3. 安装 Powerlevel10k 主题

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 国内用户可以使用 gitee.com 官方镜像加速
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Starship 已作为首选提示符接入 `zshrc`；检测到 `starship` 命令时会自动停用
P10k。P10k 文件仍保留，作为 Starship 不可用时的回退方案。

### 4. 安装 Starship（推荐提示符）

官方安装脚本（安装前请查看脚本内容，并按你的系统包管理策略选择方式）：

```bash
curl -sS https://starship.rs/install.sh | sh
```

也可以使用发行版包管理器或 Cargo 安装。确认安装成功：

```bash
starship --version
```

本仓库的 `install.sh` 会将 `starship/starship.toml` 链接到
`${XDG_CONFIG_HOME:-~/.config}/starship.toml`，然后执行 `exec zsh` 即可生效。

### 5. 安装 zsh-autosuggestions（命令提示插件）

输入命令时自动推测你可能需要的命令，按右键快速采用建议：

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 国内用户可使用以下镜像加速（任选其一）
git clone https://github.moeyy.xyz/https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### 6. 安装 zsh-syntax-highlighting（语法高亮插件）

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 国内用户镜像加速
git clone https://github.moeyy.xyz/https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 7. 内置插件说明（无需额外安装）

以下插件由 Oh My Zsh 内置，配置中已启用，无需额外安装：

| 插件 | 功能 |
|------|------|
| `git` | Git 快捷别名与补全 |
| `z` | 文件夹快捷跳转：对曾经跳转过的目录，输入目标文件夹名即可快速跳转 |
| `extract` | 统一解压命令：无需记忆不同压缩格式的对应命令 |
| `colored-man-pages` | 为 man 手册页添加语法高亮 |
| `colorize` | 为文件内容添加语法高亮（需配合 ccat/pygmentize） |
| `cp` | 为 `cp` 添加进度条（rsync 模式） |
| `command-not-found` | 输入不存在的命令时提示应安装的包 |
| `sudo` | 双击 Esc 为当前/上一条命令添加 sudo 前缀 |
| `history-substring-search` | 历史子串搜索 |
| `docker` | Docker 命令补全 |
| `npm` | npm 命令补全 |

## 自定义功能

### WSL 代理开关

本配置提供了 `proxy` / `unproxy` 函数，自动检测 Windows 宿主机 IP 并设置代理环境变量。

默认代理端口为 `7899`，如需修改请编辑 `zshrc` 中 `proxy()` 函数内的 `proxy_port` 变量。

```bash
# 开启代理
proxy

# 关闭代理
unproxy
```

### Docker 容器快速进入

`denter` 函数可一键启动并进入 Docker 容器：

```bash
# 用法
denter <容器名> [工作目录] [用户] [shell]

# 示例：以 root 身份进入容器 /workspace 目录
denter my-container /workspace root /bin/bash
```

支持 Tab 自动补全容器名。

### 私密密钥管理

API 密钥等敏感信息通过 `~/.zshenv.local` 文件管理，该文件在 `zshrc` 末尾被动态加载（如果存在）。请勿将密钥写入本仓库的配置文件中。

示例 `~/.zshenv.local`：

```bash
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxx"
# 其他私密环境变量...
```

## 一键安装顺序

```bash
# 1. 安装系统依赖
sudo apt update && sudo apt install zsh git curl -y

# 2. （可选）设置默认 shell；不执行也不影响本仓库配置
# chsh -s "$(which zsh)"
# 注销并重新登录

# 3. 安装 Oh My Zsh
sh -c "$(curl -fsSL https://install.ohmyz.sh/)"

# 4. 安装 Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 5. 安装 Starship（推荐提示符）
curl -sS https://starship.rs/install.sh | sh

# 6. 安装插件
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 7. 部署配置文件
cd ~/Document/dotfile
./install.sh
```
