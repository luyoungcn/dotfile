-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 右键菜单和补全菜单使用 Pmenu；关闭背景混合，避免与后方文字重叠
vim.opt.pumblend = 0

-- 默认隐藏 LSP 诊断；需要时仍可用 <leader>ud 切换显示
vim.diagnostic.enable(false)

-- 默认关闭保存时自动格式化（conform.nvim format-on-save）
-- 需要时可手动格式化，或按 <leader>uf 切换回自动格式化
vim.g.autoformat = false
