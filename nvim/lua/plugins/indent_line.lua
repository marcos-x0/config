return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    scope = {
      char = '┃', -- Solid vertical line for the current scope
      highlight = 'IndentScopeHighlight', -- Link to the custom Nord highlight group
      enabled = true, -- Enable scope highlighting
      show_start = false, -- Show the start of the current context
      show_end = false, -- Optionally disable the end marker
    },
    indent = {
      char = '┊', -- Customize the indent character if desired
    },
  },
}
