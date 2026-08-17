return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        snacks_win_opts = {
          position = "float",
          width = 0.82,
          height = 0.85,
          border = "rounded",
          backdrop = 60,
          title = " Claude Code ",
          title_pos = "center",
          keys = {
            claude_hide = {
              "<C-\\><C-n>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Hide Claude Code",
            },
          },
        },
      },
    },
  },
}
