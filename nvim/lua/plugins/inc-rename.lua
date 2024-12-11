return {
  'smjonas/inc-rename.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('inc_rename').setup {
      -- input_buffer_type = 'dressing',
      -- input = {
      --
      --   border = {
      --     style = 'rounded', -- Border style: "none", "single", "double", "rounded"
      --     highlight = 'FloatBorder',
      --   },
      --   win_options = {
      --     winblend = 15, -- Semi-transparent floating window
      --     winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
      --   },
      --   anchor = 'SW', -- Anchor position (e.g., South-West of the cursor)
      --   relative = 'cursor',
      -- },
    }
  end,
}
