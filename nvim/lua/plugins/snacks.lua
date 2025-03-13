---@diagnostic disable: assign-type-mismatch
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
        explorer = {
          auto_close = true,
          layout = { preset = "default", preview = true, layout = { backdrop = true } },
          -- your explorer picker configuration comes here
          -- or leave it empty to use the default settings
        },
        buffers = { current = false },
      },
      layout = {
        layout = { backdrop = true },
        preset = "dropdown",
      },
    },
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
