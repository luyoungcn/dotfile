-- lua/plugins/solarized.lua
return {
  -- 1. 告诉 LazyVim 默认全局配色为 solarized
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
  -- 2. Solarized 主题配置（maxmx03/solarized.nvim，Lua 实现，支持真彩色）
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- 使用 solarized 调色板（另有 "selenized" 可选）
      palette = "solarized",
      -- 透明背景
      transparent = { enabled = true },
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
    config = function(_, opts)
      -- 强制深色背景，确保使用 solarized dark 调色板
      vim.o.background = "dark"
      require("solarized").setup(opts)
    end,
  },
}
