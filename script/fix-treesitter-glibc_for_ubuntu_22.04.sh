#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# fix-treesitter-glibc.sh
#
# 解决 Ubuntu 22.04 上 nvim-treesitter 安装 parser 时报
#   tree-sitter: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
#
# 原因:mason 安装的 tree-sitter-cli 是官方预编译二进制(v0.26.x),
#       在 glibc 2.39 (Ubuntu 24.04) 上构建;22.04 只有 glibc 2.35,无法运行。
# 原理:在本机从源码编译 tree-sitter-cli(链接本机 glibc),替换 mason 的二进制。
#
# 用法:bash fix-treesitter-glibc.sh
# 幂等:mason 更新覆盖二进制后可随时重跑。
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_NC='\033[0m'
log()  { printf "${C_GREEN}[*]${C_NC} %s\n" "$*"; }
warn() { printf "${C_YELLOW}[!]${C_NC} %s\n" "$*"; }
die()  { printf "${C_RED}[x]${C_NC} %s\n" "$*" >&2; exit 1; }

MASON_PKG="$HOME/.local/share/nvim/mason/packages/tree-sitter-cli/tree-sitter-linux-x64"
MASON_BIN="$HOME/.local/share/nvim/mason/bin/tree-sitter"
CARGO_BIN="$HOME/.cargo/bin/tree-sitter"

# ───────────────────────── 1. 前置检查 ─────────────────────────
log "检查前置条件..."
command -v curl >/dev/null 2>&1 || die "缺少 curl,请先安装:sudo apt-get install -y curl"
if ! command -v cc >/dev/null 2>&1; then
  warn "缺少 C 编译器,安装 build-essential(需要 sudo 密码)..."
  sudo apt-get update && sudo apt-get install -y build-essential
fi

# arm64 等架构下 mason 包内文件名不同,自动探测
if [ ! -e "$MASON_PKG" ] && [ -d "$(dirname "$MASON_PKG")" ]; then
  FOUND=$(find "$(dirname "$MASON_PKG")" -maxdepth 1 -type f -name 'tree-sitter-linux-*' -print -quit 2>/dev/null || true)
  [ -n "${FOUND:-}" ] && MASON_PKG="$FOUND"
fi

# ───────────────────────── 2. Rust 工具链 ─────────────────────────
# Ubuntu 22.04 apt 源的 rustc(1.59)太旧,编不了 tree-sitter 0.26.x,必须用 rustup
if ! command -v rustup >/dev/null 2>&1 || ! command -v cargo >/dev/null 2>&1; then
  log "安装 Rust 工具链 (rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal --default-toolchain stable
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
else
  log "已检测到 rustup,确保 stable 工具链可用..."
  rustup toolchain install stable --no-self-update || true
fi

# ───────────────────────── 3. 本机编译 ─────────────────────────
log "编译 tree-sitter-cli(首次约 3~8 分钟,请耐心等待)..."
cargo install tree-sitter-cli

# ───────────────────────── 4. 替换 mason 二进制 ─────────────────────────
log "替换 mason 安装的预编译二进制..."
mkdir -p "$(dirname "$MASON_PKG")" "$(dirname "$MASON_BIN")"
ln -sf "$CARGO_BIN" "$MASON_PKG"
ln -sf "$CARGO_BIN" "$MASON_BIN"

# ───────────────────────── 5. 验证 ─────────────────────────
log "验证替换后的二进制..."
if ! "$MASON_BIN" --version >/dev/null 2>&1; then
  die "替换后的 tree-sitter 仍无法运行,请保留上方完整输出以便排查"
fi
"$MASON_BIN" --version

if command -v objdump >/dev/null 2>&1; then
  MAX_GLIBC=$(objdump -T "$CARGO_BIN" \
    | grep -oE 'GLIBC_[0-9.]+' | sed 's/GLIBC_//' | sort -V | tail -1)
  log "本机编译的二进制最高要求 GLIBC_${MAX_GLIBC}(Ubuntu 22.04 自带 2.35)"
fi

log "当前 shell PATH 中的 tree-sitter 位于:$(command -v tree-sitter 2>/dev/null || echo '未找到')"

# ───────────────────────── 6. 重建全部 parser ─────────────────────────
# 新版 nvim-treesitter 的用户命令内部都是同步等待的(async 库的 arun 阻塞主循环
# 直到任务完成,所以旧版才把 TSUpdateSync 移除了),headless 下同样可靠。
if command -v nvim >/dev/null 2>&1; then
  log "在 nvim 中重建全部 parser(:TSUpdate 阻塞执行,约需几分钟)..."
  nvim --headless -c "TSUpdate" -c "qa"
  log "parser 重建完成。若上方输出仍有 error,请进入 nvim 用 :TSLog 排查"
else
  warn "未找到 nvim 命令,请稍后进入 nvim 手动执行 :TSUpdate"
fi

cat <<'EOF'

[*] 全部完成!若以后 mason 更新覆盖了二进制,重跑本脚本即可(幂等)。
EOF
