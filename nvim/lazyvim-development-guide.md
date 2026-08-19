# 终端与 Neovim 开发环境配置手册

> 一份面向日常开发的 LazyVim 安装、插件管理、快捷键与界面定制指南。
>
> 当前配置基线：**Catppuccin Mocha + 自动适配的 Catppuccin 状态栏 + 状态栏斜线分隔 + bufferline 顶部 Buffer Tab 斜角分隔**。

## 目录

- [1. 核心精髓](#1-核心精髓-tldr)
- [2. 知识网络与概念解构](#2-知识网络与概念解构-the-knowledge-graph)
- [3. 底层逻辑与技术架构分析](#3-底层逻辑与技术架构分析-deep-dive)
- [4. AI 编程助手使用指南](#4-ai-编程助手使用指南)
- [5. 行动指南与复盘反思](#5-行动指南与复盘反思-actionable-insights)
- [附录：快捷键速查](#附录快捷键速查)

## 1. 核心精髓 (TL;DR)

**一句话总结：** LazyVim 提供一套可扩展的 Neovim 基础层；通过 LazyExtras 开启语言和 AI 能力，通过 `:Lazy` 管理插件，通过稳定的 `<leader>` 快捷键完成搜索、Buffer、窗口、Git、终端、诊断和 AI 协作，再用 `lua/plugins/` 中的插件规格维护自己的配置。

### Key Takeaways

1. **先准备运行环境，再安装 LazyVim。** Neovim、Git、编译器、Nerd Font、Ripgrep 和 fd 分别承担编辑器运行、插件获取、Treesitter 编译、图标显示和文件/文本搜索职责。
2. **把 LazyVim Extras 当作语言栈入口。** 在 `:LazyExtras` 中启用语言扩展，通常会联动 LSP、格式化、Treesitter、调试和 Mason 配置。
3. **把个人修改放进 `lua/plugins/`。** 当前界面配置集中在 `lua/plugins/ui.lua`：主题固定为 Catppuccin Mocha，lualine 使用 `auto` 自动适配主题并采用斜线分隔，bufferline 使用 Catppuccin integration、彩色图标、始终显示和斜角分隔，Noice 消息通过 Snacks notifier 宽屏换行显示。
4. **让 Copilot 与 Claude Code 分工。** Copilot 作为 `blink.cmp` 补全源处理输入时的短补全；Claude Code 通过浮动终端、上下文发送和原生 Diff 处理解释、重构、测试与跨文件任务。

### 当前界面配置的最终效果

- 颜色主题：`catppuccin-mocha`
- 底部 Status Line：lualine 使用 `auto` 自动适配 Catppuccin
- 顶部 Buffer Tab：`bufferline.nvim`
- Status Line 分隔符：lualine 的 `` / `` 斜线风格
- Buffer Tab 分隔符：`slant`，即梯形斜角风格
- Buffer Tab：始终显示，即使只打开一个文件也可见
- 图标：启用彩色文件类型图标
- 当前 Buffer：使用 Catppuccin 高亮和粗体强调
- 关闭按钮：隐藏，减少视觉噪声
- 消息弹窗：最大宽度和高度均为编辑区的 `90%`，长路径与文本自动换行完整显示
- 右键与补全菜单：`pumblend = 0`，使用完全不透明的 Catppuccin 背景

## 2. 知识网络与概念解构 (The Knowledge Graph)

### LazyVim

**通俗解释：** LazyVim 是建立在 Neovim 和 lazy.nvim 之上的配置框架，提供默认按键、插件规格、界面组件和合理的开发工作流。

**文中上下文：** 安装 LazyVim Starter 后，用户主要通过 `lua/config/` 修改基础设置，通过 `lua/plugins/` 添加或覆盖插件配置，而不是直接修改 LazyVim 本体。

**实践价值：** 保持上游配置可更新，个人配置也更容易迁移到新的机器。

### lazy.nvim

**通俗解释：** lazy.nvim 是插件管理器，负责插件安装、更新、懒加载、依赖解析和状态查看。

**文中上下文：** 首次启动时它会安装插件；插件前的加载状态、触发条件和错误信息可以在 `:Lazy` 中查看。

**实践价值：** 通过 `event`、`keys`、`cmd` 等触发条件延后加载插件，降低启动成本。

### LazyExtras

**通俗解释：** LazyVim 的可选功能模块集合。语言扩展通常以 `lang.<language>` 命名。

**文中上下文：** 在 `:LazyExtras` 中找到目标语言，按 `x` 开启，例如 `lang.clangd`、`lang.python`。

**实践价值：** 减少手写 LSP、格式化工具、Treesitter 和调试器的重复配置。

### Buffer、Window 与 Buffer Tab

**通俗解释：** Buffer 是编辑器中的文件内容，Window 是显示 Buffer 的屏幕区域，Buffer Tab 是对多个 Buffer 的可视化导航条。

**文中上下文：** 顶部标签页看起来像传统 Tab，但 LazyVim 默认使用的是 bufferline 管理 Buffer，而不是 Vim 的原生 Tab 页面。

**实践价值：** 理解这个区别后，可以用 `H/L` 切换 Buffer，用窗口快捷键管理布局，不会把“切文件”和“切分屏”混为一谈。

### Catppuccin 与 bufferline 配色

**通俗解释：** Catppuccin 是颜色主题；bufferline 是顶部 Buffer Tab 插件。两者通过高亮组连接，而不是由 bufferline 自己决定整套颜色。

**文中上下文：** 当前配置通过 Catppuccin 的 `integrations.bufferline = true` 提供 Buffer Tab、图标、诊断和修改状态的统一高亮，不再手动调用内部高亮模块路径。

**实践价值：** 更换主题时，可以优先寻找对应的 bufferline integration，而不是为每个高亮组手动写颜色。

### Noice 与 Snacks 消息链路

**通俗解释：** Noice 负责接管和分类 Neovim 的消息、命令行及通知；当前 LazyVim 版本再把普通消息交给 Snacks notifier 绘制右上角弹窗。

**文中上下文：** 消息是否被路由、合并或保存由 Noice 决定，但弹窗的宽度、高度和换行行为由 `snacks.nvim` 的 `notifier` 与 `notification` style 决定。仅修改 Noice 的 `views.notify` 不一定能改变最终弹窗尺寸。

**实践价值：** 排查消息显示问题时先区分“消息路由”和“弹窗渲染”，再修改真正生效的配置层，避免长路径因默认 `40%` 最大宽度和关闭换行而显示不全。

## 3. 底层逻辑与技术架构分析 (Deep Dive)

### 3.1 安装链路

LazyVim 的安装和初始化大致遵循以下流程：

```text
系统依赖
  ├─ Neovim / Git / C 编译器
  ├─ Nerd Font
  └─ ripgrep / fd
        │
        ▼
备份现有 Neovim 数据与配置
        │
        ▼
克隆 LazyVim Starter
        │
        ▼
首次启动：lazy.nvim 解析并安装插件
        │
        ▼
:LazyExtras 开启语言栈
        │
        ▼
lua/config 与 lua/plugins 承载个人配置
```

### 3.2 依赖清单

| 依赖 | 最低/建议版本 | 检查命令 | 主要职责 |
|---|---:|---|---|
| Neovim | `>= 0.9.0`，建议 `0.10+` | `nvim --version` | 编辑器核心 |
| Git | `>= 2.19` | `git --version` | 拉取和更新插件 |
| C 编译器 | gcc 或 clang | `gcc --version` / `clang --version` | 编译 Treesitter 解析器 |
| Nerd Font | 任意 | 终端字体设置 | 显示图标 |
| Ripgrep | 最新版 | `rg --version` | Telescope 全文搜索 |
| fd | 最新版 | `fd --version` | Telescope 文件搜索 |

Ripgrep 与 fd 的安装示例：

```bash
# macOS
brew install ripgrep fd

# Ubuntu / Debian
sudo apt install ripgrep fd-find
```

### 3.3 备份与安装

先备份原有配置和运行数据：

```bash
mv ~/.config/nvim      ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim       ~/.cache/nvim.bak
```

然后克隆 Starter 模板：

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
```

> 注意：以上 `mv` 命令会覆盖同名备份路径的使用意图，执行前应确认 `.bak` 路径不存在。若需要保留多份备份，请使用带日期的明确目录名。

首次启动时，lazy.nvim 会下载和编译核心插件。等待 `:Lazy` 界面中的任务完成后，建议完全退出并重新打开一次 Neovim。

### 3.4 插件加载状态

在 Neovim 中执行 `:Lazy` 可以查看插件状态。常见符号含义如下：

| 符号 | 含义 | 说明 |
|---|---|---|
| `●` | Loaded | 插件已经载入并运行 |
| `○` | Not Loaded | 已注册但尚未满足加载条件 |
| `⚡` | Event / Key | 由事件或快捷键触发懒加载 |
| `󰏔` | Plugin | 普通插件 |
| `` | Local | 使用 `dir` 引入的本地插件 |
| `󰂖` / `❌` | Error | 插件加载失败或配置报错 |

典型状态变化：

```text
○ Not Loaded
      │ 触发 event / key / cmd
      ▼
● Loaded
```

选中插件后按 `Enter`，右侧通常可以看到插件的加载条件和详细信息。

### 3.5 当前 Buffer Tab 配置

文件位置：`~/.config/nvim/lua/plugins/ui.lua`

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      integrations = {
        bufferline = true,
        lualine = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        separator_style = "slant",
        color_icons = true,
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        indicator = { style = "icon", icon = "▎" },
      })

      -- Catppuccin 通过 integrations.bufferline 自动提供高亮
    end,
  },
}
```

#### 配置项说明

| 配置项 | 作用 |
|---|---|
| `colorscheme = "catppuccin"` | 将 LazyVim 默认主题切换为 Catppuccin |
| `flavour = "mocha"` | 固定为深色的 Catppuccin Mocha 风格 |
| `section_separators` | 使用斜线分隔 lualine 状态栏的主要区段 |
| `component_separators` | 使用细斜线分隔 lualine 状态栏组件 |
| `separator_style = "slant"` | 使用梯形斜角风格分隔顶部 Buffer Tab |
| `color_icons = true` | 启用文件类型图标的颜色 |
| `always_show_bufferline = true` | 只有一个 Buffer 时也显示顶部标签栏 |
| `indicator = { style = "icon", icon = "▎" }` | 用粗竖线强调当前 Buffer |
| `show_buffer_close_icons = false` | 隐藏每个 Buffer 上的关闭按钮 |
| `show_close_icon = false` | 隐藏标签栏最右侧的全局关闭按钮 |
| `integrations.bufferline = true` | 让 Catppuccin 自动提供标签、图标、诊断和修改状态配色 |

#### 分隔符名称的视觉含义

需要注意：本配置同时使用两种斜线配置：lualine 通过 Powerline 字符（`` / ``）配置底部状态栏，bufferline 通过 `separator_style = "slant"` 配置顶部梯形斜角标签。

lualine 使用：

```lua
opts.options.section_separators = { left = "", right = "" }
opts.options.component_separators = { left = "", right = "" }
```

常用候选值：

| 值 | 视觉效果 |
|---|---|
| `"thick"` | 粗线/粗竖线 |
| `"thin"` | 细线分隔 |
| `"slant"` | 梯形斜角标签 |
| `"padded_slant"` | 带额外留白的斜角标签 |
| `"slope"` | 更明显的坡形分隔 |
| `"default"` | 插件默认样式 |

### 3.6 主题加载与验证

LazyVim 的默认颜色主题是 Tokyonight；仅安装 Catppuccin 插件并不会自动切换主题，必须明确设置 `colorscheme = "catppuccin"`。

启动后可以执行以下命令验证：

```vim
:lua print(vim.g.colors_name)
```

预期结果：

```text
catppuccin-mocha
```

若输出 `tokyonight-moon`，说明当前启动配置仍使用 LazyVim 默认主题，优先检查 `lua/plugins/ui.lua` 是否包含 LazyVim 主题覆盖配置，并完全退出后重新启动 Neovim。

也可以检查 bufferline 的关键设置：

```vim
:lua print(require("bufferline.config").options.separator_style)
```

预期结果：

```text
slant
```

### 3.7 消息弹窗与长文本显示

LazyVim 默认由 Noice 接管消息；在当前插件版本中，Noice 的 `notify` view 优先使用 Snacks backend。Snacks notifier 默认最大宽度为编辑区的 `40%`，且 `notification` style 的 `wrap` 为 `false`，因此长路径或长文本可能在弹窗中被截断。

当前配置在 `lua/plugins/ui.lua` 中覆盖 Snacks：

```lua
{
  "folke/snacks.nvim",
  opts = {
    notifier = {
      width = { min = 40, max = 0.9 },
      height = { min = 1, max = 0.9 },
    },
    styles = {
      notification = {
        wo = {
          wrap = true,
          linebreak = true,
        },
      },
    },
  },
}
```

`max = 0.9` 表示弹窗最多占编辑区对应尺寸的 `90%`；`wrap = true` 让超过窗口宽度的内容继续换行；`linebreak = true` 尽量在合适的文本边界换行。三者配合后，长路径和消息会完整显示，同时仍给主编辑区保留少量可见空间。

若消息已经消失，可按 `Space n` 打开通知历史；Noice 自身的最近消息和历史记录还可分别通过 `Space s n l` 与 `Space s n h` 查看。修改配置后需重启 Neovim，或者重新加载相关插件配置，已有弹窗不会自动采用新尺寸。

### 3.8 右键菜单透明度

Neovim 的右键上下文菜单和补全菜单都使用 `Pmenu` 高亮组。LazyVim 默认设置 `pumblend = 10`，会将菜单背景与后方编辑区进行透明混合；文字密集时，两层内容容易视觉重叠。

当前在 `lua/config/options.lua` 中覆盖为：

```lua
vim.opt.pumblend = 0
```

`0` 表示不进行背景混合，菜单直接使用 Catppuccin 的 `Pmenu` 实色背景。这个设置会同时影响右键菜单和插入模式补全菜单，但不会改变 Noice/Snacks 消息弹窗的透明度；普通浮动窗口由 `winblend` 或插件自身的 window style 控制。

可以在 Neovim 中查看当前值和高亮组：

```vim
:set pumblend?
:hi Pmenu
```

修改后重启 Neovim 即可生效；当前会话也可执行 `:set pumblend=0` 立即验证。

### 3.9 边界、故障模式与约束

#### 主题选择器会临时改变当前会话

通过 `:Telescope colorscheme`、`:Snacks picker colorschemes` 或其他主题选择器切换主题，通常只会改变当前 Neovim 会话。重启后是否恢复，取决于默认配置是否正确。

#### 主题配置可能被后续规格覆盖

LazyVim 会合并多个插件规格。若同一个插件被多个规格重复配置，后加载的 `opts`、`config` 或主题初始化逻辑可能影响最终效果。排查时应以运行时结果为准：

```vim
:lua print(vim.g.colors_name)
:Lazy
```

#### 终端颜色会影响观感

Catppuccin 使用终端的真彩色能力。若终端未开启 24-bit color，颜色可能被近似成另一套主题，看起来不像预期效果。可在 Neovim 中检查：

```vim
:lua print(vim.o.termguicolors)
```

通常应为 `true`。

#### Nerd Font 缺失会导致图标异常

主题配色仍会生效，但文件图标、粗竖线或其他特殊字符可能显示成方框。请在终端中配置 Nerd Font，例如 JetBrainsMono Nerd Font。

#### 消息内容过长仍受屏幕物理尺寸限制

自动换行可以防止单行被截断，但弹窗最终仍不能超过当前终端尺寸。极长的多行输出更适合在通知历史或 Noice history 中阅读；LazyVim 的 `long_message_to_split` preset 也会把部分长消息转入 split 窗口。

### 3.10 方案对比

| 维度 | Catppuccin Mocha + lualine auto + 双层 slant | Tokyonight Moon + 默认 bufferline | 仅 bufferline `slant` |
|---|---|---|---|
| 主题 | 柔和深色、低刺激 | 深色蓝紫调 | 取决于外层主题 |
| 标签分隔 | 顶部梯形斜角；底部状态栏斜线 | 默认样式 | 顶部梯形斜角 |
| 单 Buffer 可见性 | 是 | 由默认配置决定 | 由 `always_show_bufferline` 决定 |
| 配色一致性 | Catppuccin 提供 bufferline integration | 依赖 Tokyonight 配置 | 主要改变形状，不改变主题 |
| 视觉复杂度 | 中等、清晰 | 默认、克制 | 更装饰性 |

## 4. AI 编程助手使用指南

### 4.1 当前 AI 配置与分工

当前在 `lazyvim.json` 中启用了两个 LazyVim AI Extra：

| 能力 | 插件/集成 | 适合的任务 | 当前行为 |
|---|---|---|---|
| 输入时补全 | GitHub Copilot + `blink.cmp` | 补全一行、函数体、样板代码 | 自动触发，结果进入统一补全菜单 |
| 对话式编程 | `coder/claudecode.nvim` + Claude Code CLI | 解释代码、重构、修复、测试、跨文件修改 | 在居中浮动终端中运行，可接收 Buffer、选区和文件上下文 |

本地 Claude Code 覆盖配置位于 `lua/plugins/claudecode.lua`。浮窗宽度为编辑区的 `82%`，高度为 `85%`，标题为 `Claude Code`；在其终端中按 `Ctrl+\`，再按 `Ctrl+n` 可隐藏浮窗并返回编辑区。

这两套能力互不替代：写代码时先用 Copilot 降低重复输入；任务需要描述意图、理解上下文、执行命令或修改多个文件时，再交给 Claude Code。

### 4.2 首次使用与状态检查

Claude Code 依赖本机 `claude` 命令。当前环境已安装 Claude Code CLI；若新机器尚未登录，先在终端运行：

```bash
claude
```

按 CLI 提示完成 Anthropic 认证。进入 Neovim 后，按 `Space a c` 打开或关闭 Claude Code 浮窗。

Copilot 首次使用需要 GitHub 授权：

```vim
:Copilot auth
```

按照提示完成设备授权。状态栏中的 Copilot 图标可反映连接状态；也可运行 `:Copilot auth info` 检查当前账号。AI 插件异常时，先用 `:Lazy` 检查插件加载或更新状态，再用 `:checkhealth` 查看环境问题。

### 4.3 Copilot：随写随用的代码补全

当前 `vim.g.ai_cmp = true`，Copilot 建议由 `blink.cmp` 展示，而不是单独显示为灰色幽灵文本。建议的日常操作如下：

1. 进入插入模式，先写清晰的函数名、类型签名、注释或一小段实现。
2. 等待统一补全菜单出现；带 Copilot/AI 图标的候选项来自 Copilot。
3. 使用 `Ctrl+n` / `Ctrl+p` 选择下一个或上一个候选。
4. 按 `Enter` 接受当前选中的候选；也可按 `Ctrl+y` 直接选择并接受。
5. 按 `Ctrl+e` 关闭补全菜单；未出现菜单时按 `Ctrl+Space` 手动触发。

| 插入模式操作 | 快捷键 |
|---|---|
| 手动显示补全 | `Ctrl+Space` |
| 下一个/上一个候选 | `Ctrl+n` / `Ctrl+p` |
| 接受当前候选 | `Enter` |
| 选择并接受候选 | `Ctrl+y` |
| 关闭补全菜单 | `Ctrl+e` |

Copilot 对“局部且意图明确”的任务效果最好，例如先写注释 `-- parse config and return validation errors`、测试用例名或带返回类型的函数签名，再让它补全实现。生成后仍需检查边界条件、错误处理、依赖 API 和测试结果。

### 4.4 Claude Code：基础操作与快捷键

以下快捷键以 `<leader> = Space` 为前提，主要在普通模式使用：

| 操作 | 快捷键 | 说明 |
|---|---|---|
| 打开/关闭 Claude | `Space a c` | 切换 Claude Code 浮窗 |
| 聚焦 Claude | `Space a f` | 会话存在时把焦点移到浮窗 |
| 恢复历史会话 | `Space a r` | 使用 `claude --resume` 选择并恢复会话 |
| 继续最近会话 | `Space a C` | 使用 `claude --continue` 继续最近会话，注意大写 `C` |
| 添加当前 Buffer | `Space a b` | 将当前文件加入 Claude 上下文 |
| 发送可视选区 | 可视模式 `Space a s` | 发送所选代码及行号 |
| 从文件树添加文件 | 文件树中 `Space a s` | 支持当前配置使用的 Neo-tree |
| 接受 Claude Diff | `Space a a` | 接受当前提议修改 |
| 拒绝 Claude Diff | `Space a d` | 拒绝当前提议修改 |
| 隐藏 Claude 浮窗 | 终端模式 `Ctrl+\`，再按 `Ctrl+n` | 返回原编辑窗口 |

按下 `Space a` 后稍等，WhichKey 会显示当前可用的 AI 子命令。`Space a c` 是开关窗口，`Space a f` 是聚焦已有窗口，两者用途不同。

### 4.5 常用 Case

#### 解释一段代码

1. 用可视模式选中目标代码。
2. 按 `Space a s` 将选区发送给 Claude。
3. 按 `Space a f` 聚焦 Claude，再输入“解释这段代码的控制流、隐含假设和边界条件”。

发送选区比只说“解释当前代码”更精确，也能把文件路径和行号一并交给 Claude。

#### 重构当前文件

1. 在目标文件按 `Space a b` 添加整个 Buffer。
2. 按 `Space a f` 聚焦 Claude。
3. 明确约束，例如“提取重复逻辑，不改变公共 API；修改后运行现有测试”。
4. Claude 提交修改后逐个检查 Diff，再用 `Space a a` 接受或 `Space a d` 拒绝。

需求只涉及局部函数时，优先发送选区，避免加入无关上下文；需要理解完整模块时再添加整个 Buffer。

#### 跨文件修改

1. 按 `Space e` 打开 Neo-tree。
2. 在相关文件上按 `Space a s`，可对多个文件重复操作。
3. 打开 Claude 后说明目标、兼容性约束和验证命令。
4. 审核每个文件的 Diff，并在完成后亲自运行测试或构建。

#### 根据报错修复问题

先将报错对应的代码选区发送给 Claude，再在提示中粘贴完整错误信息和复现步骤。一个高质量请求应包含：预期行为、实际行为、最小复现、不能改变的接口，以及应运行的测试命令。

#### 生成或补充测试

添加待测 Buffer 后，要求 Claude 先阅读仓库现有测试风格，再覆盖正常路径、边界输入和失败路径。不要只要求“提高覆盖率”；应指出行为契约，并检查生成的断言是否真正验证结果。

#### 恢复之前的任务

- `Space a C`：直接延续最近一次会话，适合刚刚中断的工作。
- `Space a r`：从历史会话中选择，适合切回较早的任务。

恢复后先让 Claude 简述当前目标、已完成修改和剩余验证，避免在过期假设上继续编辑。

### 4.6 Diff 审核与安全边界

Claude 提议修改时会打开 Neovim 原生 Diff。此时可以像普通 Buffer 一样检查甚至调整内容：

- `Space a a` 或 `:w`：接受当前 Diff。
- `Space a d` 或 `:q`：拒绝当前 Diff。
- `:ClaudeCodeCloseAllDiffs`：清理仍悬挂的待处理 Diff；不会丢弃已经接受并保存的修改。

接受 AI 修改前至少检查公共接口、错误处理、删除内容、依赖变化和测试结果。不要把令牌、私钥、生产数据或未脱敏日志发送给外部 AI 服务；涉及删除、迁移、发布和生产命令时，要求 Claude 先说明计划，并由人确认实际命令和目标范围。

### 4.7 常见问题

| 现象 | 排查方式 |
|---|---|
| `Space a c` 无响应 | 用 `:Lazy` 确认 `claudecode.nvim` 已安装；在 shell 中运行 `claude --version` |
| Claude 浮窗内快捷键像普通文字一样输入 | 当前处于终端插入状态；按 `Ctrl+\`，再按 `Ctrl+n` 隐藏并回到编辑区 |
| Copilot 没有候选 | 运行 `:Copilot auth info`，确认网络和授权；输入几字符或按 `Ctrl+Space` |
| 看不到独立灰字建议 | 这是当前配置的预期行为；Copilot 已集成进 `blink.cmp` 菜单 |
| AI 候选被普通 LSP 候选遮住 | 用 `Ctrl+n` / `Ctrl+p` 浏览候选，并根据 Copilot 图标识别来源 |
| Diff 窗口残留 | 执行 `:ClaudeCodeCloseAllDiffs`，再检查 `:ClaudeCodeStatus` |

## 5. 行动指南与复盘反思 (Actionable Insights)

### 安装与初始化

1. **检查依赖。** 确认 `nvim`、Git、C 编译器、Nerd Font、`rg` 和 `fd` 均可用。
2. **备份现有目录。** 先处理 `~/.config/nvim`、`~/.local/share/nvim`、`~/.local/state/nvim` 和 `~/.cache/nvim`，再克隆 Starter。
3. **完成首次插件安装。** 启动 Neovim，等待 `:Lazy` 任务完成，退出并重新启动。
4. **开启语言扩展。** 使用 `:LazyExtras` 开启目标语言，例如 `lang.python` 或 `lang.clangd`。
5. **固定个人配置。** 将主题、bufferline 和其他 UI 修改放在 `lua/plugins/ui.lua`，不要直接改 LazyVim 安装目录。

### 日常工作流

1. **搜索文件：** `Space f f`；全文搜索：`Space s g`；最近文件：`Space f r`。
2. **管理 Buffer：** `Shift+h` / `Shift+l` 切换左右 Buffer，`Space b d` 关闭当前 Buffer。
3. **管理窗口：** `Ctrl+h/j/k/l` 移动窗口，`Space |` 或 `Space w v` 垂直分屏，`Space -` 或 `Space w s` 水平分屏。
4. **使用 Git：** `Space g g` 打开 Lazygit，`]h` / `[h` 跳转 Git 修改点，`Space g h p` 预览 Hunk，`Space g b` 查看 Blame。
5. **使用终端：** `Space f t` 或 `Ctrl+/` 呼出浮动终端。
6. **处理诊断：** `Space u d` 切换诊断显示，`Space c d` 查看当前报错详情。
7. **使用 AI：** 小范围输入用 Copilot 补全；选区解释用可视模式 `Space a s`；文件级任务先 `Space a b`，再 `Space a f`；所有 Claude 修改都逐个审核 Diff。

### 认知盲区与反常识点

- **顶部“Tab”不一定是 Vim Tab。** LazyVim 顶部显示的是 Buffer Tab，和 `:tabnew` 创建的 Tab 页面不是同一个概念。
- **底部状态栏和顶部 Buffer Tab 都可以使用 slant，但配置入口不同。** lualine 通过 Powerline 字符配置斜线；bufferline 通过 `separator_style` 配置标签形状。
- **安装主题不等于启用主题。** Catppuccin 插件存在于运行环境中，不代表当前主题已经切换；必须检查 `vim.g.colors_name`。
- **只打开一个文件时看不到标签栏不一定是配置失败。** bufferline 默认可能隐藏单 Buffer 标签，因此需要设置 `always_show_bufferline = true`。
- **`:Lazy` 中的空心圆不一定是错误。** 它通常表示插件尚未满足懒加载条件；只有出现错误标记或加载日志异常时才需要排查。
- **颜色异常不一定来自 Neovim。** 终端是否支持真彩色、字体是否为 Nerd Font，也会直接改变最终观感。

## 附录：快捷键速查

> 以下快捷键以 `<leader> = Space` 为前提。

### 搜索与导航

| 操作 | 快捷键 |
|---|---|
| 查找文件 | `Space f f` |
| 全文搜索 | `Space s g` |
| 最近文件 | `Space f r` |
| 文件树 | `Space e` |

Neo-tree 中：`a` 新建文件/文件夹，`A` 递归新建，`d` 删除，`r` 重命名。

### Buffer 与窗口

| 操作 | 快捷键 |
|---|---|
| 左/右 Buffer | `Shift+h` / `Shift+l` |
| 关闭 Buffer | `Space b d` |
| 垂直分屏 | `Space |` 或 `Space w v` |
| 水平分屏 | `Space -` 或 `Space w s` |
| 移动到相邻窗口 | `Ctrl+h/j/k/l` |
| 调整窗口大小 | `Ctrl+↑/↓/←/→` |

### Git、终端与诊断

| 操作 | 快捷键 |
|---|---|
| Lazygit | `Space g g` |
| 预览 Git Hunk | `Space g h p` |
| 下一个/上一个修改点 | `]h` / `[h` |
| 当前行 Blame | `Space g b` |
| 浮动终端 | `Space f t` 或 `Ctrl+/` |
| 开关诊断 | `Space u d` |
| 查看诊断详情 | `Space c d` |
| 预览窗口向下/向上滚动 | `Ctrl+f/d` / `Ctrl+b/u` |

### AI 编程助手

| 操作 | 快捷键 |
|---|---|
| 开关/聚焦 Claude | `Space a c` / `Space a f` |
| 添加当前 Buffer | `Space a b` |
| 发送选区或文件树中的文件 | `Space a s` |
| 恢复历史/继续最近 Claude 会话 | `Space a r` / `Space a C` |
| 接受/拒绝 Claude Diff | `Space a a` / `Space a d` |
| 隐藏 Claude 浮窗 | `Ctrl+\`，再按 `Ctrl+n` |
| Copilot 下一个/上一个候选 | `Ctrl+n` / `Ctrl+p` |
| 接受/关闭补全 | `Enter` 或 `Ctrl+y` / `Ctrl+e` |

---

*本文档根据当前 Neovim 配置整理；新增快捷键或插件后，应同步更新对应章节。*
