return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      window = {
        width = function()
          local columns = vim.o.columns

          if columns >= 200 then
            return 50
          elseif columns >= 150 then
            return 40
          else
            return 35
          end
        end,
      },
    },
  },
}
