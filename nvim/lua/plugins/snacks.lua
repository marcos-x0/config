---@diagnostic disable: assign-type-mismatch
local exclude = {
  "node_modules",
  ".git",
  ".jj",
  ".next",
  ".nuxt",
  "dist",
  "build",
  "target",
  "__pycache__",
  ".venv",
  "venv",
  ".mypy_cache",
  ".pytest_cache",
  ".tox",
  "vendor",
  ".gradle",
  ".cache",
  ".DS_Store",
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      matcher = { frecency = true, history_bonus = true },
      ---@class snacks.picker.formatters.Config
      formatters = { file = { filename_first = true, truncate = 100000 } },
      sources = {
        files = { hidden = true, ignored = true, exclude = exclude },
        grep = { hidden = true, ignored = true, exclude = exclude },
        explorer = {
          hidden = true,
          ignored = true,
          exclude = exclude,
          auto_close = true,
          layout = { preset = "default", preview = true, layout = { backdrop = true } },
        },
        buffers = { current = false },
      },
      layout = {
        layout = { backdrop = true },
        preset = "dropdown",
      },
    },
    image = { enabled = false },
    lazygit = { enabled = false },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- stylua: ignore start

    -- { "<leader>,", function() Snacks.picker.buffers({}) end, desc = "Buffers" },
    { "<leader>'", function() Snacks.picker.resume() end, desc = "Resume" },
    { "\\", function() Snacks.explorer() end, desc = "File Explorer" },

    -- stylua: ignore end
  },
}
