return {
  -- 1. 告诉 LazyVim 默认全局配色为 catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- 2. Catppuccin 主题配置：开启 integrations 自动注入
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      integrations = {
        bufferline = true, -- 💡 开启后自动为 bufferline 注入全套彩色高亮（无需在下面手动 require）
        lualine = true, -- 💡 开启后自动为 lualine 适配配色
      },
    },
  },

  -- 3. Lualine 状态栏（使用 auto 自动识别主题，消除 Theme not found 告警）
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = "auto", -- 💡 设为 auto，让它自动读取 Catppuccin Mocha 配色
        -- 状态栏使用斜角分隔符
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      })
    end,
  },

  -- 4. Bufferline 顶栏设置
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        -- 顶部 Buffer Tab 分隔样式 (可选: "slant" 斜角 / "thick" 粗线 / "slope" 斜坡)
        separator_style = "slant",
        color_icons = true,
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        indicator = { style = "icon", icon = "▎" },
      })
      -- 删除了过时的 require("catppuccin.special.bufferline")
    end,
  },
}
