return {
  -- Noice 通过 Snacks 显示消息：放宽弹窗并换行，避免长路径被截断
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
