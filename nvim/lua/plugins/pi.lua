-- pi (AI coding agent) integration — Plan A: bottom split terminal.
--
-- Runs the interactive `pi` TUI inside a snacks.nvim bottom split and reuses
-- the same <leader>a* prefix that claudecode.nvim provided. No deep
-- buffer/selection or diff integration yet; pi's RPC/SDK can power that
-- later if needed.

---Resolve the pi executable (absolute path when possible, so it also works
---when nvim was launched from a launcher that does not inherit the shell PATH).
local function pi_bin()
  local p = vim.fn.exepath("pi")
  return p ~= "" and p or "pi"
end

---Window options for the pi terminal split (bottom of the editor).
local function pi_term()
  return {
    win = {
      position = "bottom",
      height = 0.4,
      keys = {
        pi_hide = { "<C-\\><C-n>", "hide", mode = "t", desc = "Hide pi" },
      },
    },
  }
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>ac",
        function()
          require("snacks.terminal").toggle(pi_bin(), pi_term())
        end,
        desc = "Toggle pi",
      },
      {
        "<leader>af",
        function()
          require("snacks.terminal").focus(pi_bin(), pi_term())
        end,
        desc = "Focus pi",
      },
      {
        "<leader>ar",
        function()
          require("snacks.terminal").open(pi_bin() .. " --resume", pi_term())
        end,
        desc = "Resume pi session",
      },
      {
        "<leader>aC",
        function()
          require("snacks.terminal").open(pi_bin() .. " --continue", pi_term())
        end,
        desc = "Continue pi session",
      },
    },
  },
}
