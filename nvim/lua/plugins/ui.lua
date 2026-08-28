return {
  -- 1. Lualine 状态栏（使用 auto 自动识别主题，消除 Theme not found 告警）
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

  -- 2. Noice 通过 Snacks 显示消息：放宽弹窗并换行，避免长路径被截断
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
  },
}
