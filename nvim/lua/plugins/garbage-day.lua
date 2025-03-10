return {
  "zeioth/garbage-day.nvim",
  dependencies = "neovim/nvim-lspconfig",
  event = "VeryLazy",
  opts = {
    aggressive_mode = false,
    notifications = true,
    grace_period = 60 * 5, -- in seconds
    wakeup_delay = 1000 * 5, -- in milliseconds
    -- your config options here
  },
}
