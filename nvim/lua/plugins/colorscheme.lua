return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({})
      vim.cmd.colorscheme("nord")
    end,
    install = {
      colorscheme = { "nord" },
    },
  },
  -- "tokyonight.nvim",
  -- opts = {
  --   -- transparent = true,
  --   style = "night",
  --   styles = {
  --     -- sidebars = "transparent",
  --     -- floats = "transparent",
  --   },
  --   on_highlights = function(hl, c)
  --     -- Vertical split line
  --     -- hl.VertSplit = { fg = "#00FFFF", bg = "NONE" }
  --     -- Horizontal split line (WinSeparator covers both)
  --     hl.WinSeparator = { fg = "#565f89", bg = "NONE" }
  --   end,
  -- },
}
