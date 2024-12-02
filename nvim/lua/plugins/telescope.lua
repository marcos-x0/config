return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local util = require("lspconfig.util")
    opts.defaults = opts.defaults or {}
    opts.defaults.cwd = util.root_pattern(".git")(vim.fn.getcwd())
    opts.defaults.path_display = { "filename_first" }
    opts.defaults.layout_strategy = "vertical"
    opts.defaults.layout_config = {
      vertical = {
        preview_cutoff = 1,
        height = 0.7,
        preview_height = 0.5, -- Sets preview to 50% height of the window
      },
    }
    -- opts.defaults.layout_config = {
    --   preview_height = 0.5,
    -- }
    -- opts.defaults.layout_config = {
    --   vertical = {
    --     preview_height = 0.5, -- Sets preview to 50% height of the window
    --     -- mirror = true, -- Places the preview above the results
    --   },
    -- }
    return opts
  end,
  keys = {
    { "<leader/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (root Dir)" },
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>b", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
  },
}

-- 2024-11-12T12:52:53 Error  ERROR Unsupported layout_config key for the horizontal strategy: preview_height
