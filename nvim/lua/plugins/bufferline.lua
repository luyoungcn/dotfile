local diagnostic_icons = {
  error = " ",
  warning = " ",
  info = " ",
  hint = "󰌵 ",
  other = " ",
}

local function diagnostics_indicator(count, level)
  return (diagnostic_icons[level] or diagnostic_icons.other) .. count
end

local function configure_neo_tree_offset(offsets)
  offsets = offsets or {}

  local neo_tree = {
    filetype = "neo-tree",
    text = "File Explorer",
    highlight = "Directory",
    text_align = "center",
  }

  for index, offset in ipairs(offsets) do
    if offset.filetype == neo_tree.filetype then
      offsets[index] = vim.tbl_deep_extend("force", offset, neo_tree)
      return offsets
    end
  end

  table.insert(offsets, neo_tree)
  return offsets
end

return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      mode = "buffers",
      -- separator_style = "slant",
      separator_style = "thin", -- 细线风格，更简洁
      -- separator_style = "slope", -- 斜坡风格
      -- separator_style = "padded_slant", -- 填充斜角，兼容性更好
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = diagnostics_indicator,
    })

    opts.options.offsets = configure_neo_tree_offset(opts.options.offsets)
  end,
}
