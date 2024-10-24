return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "jay-babu/mason-null-ls.nvim",
    "davidmh/cspell.nvim",
  },
  config = function()
    -- Setup Mason
    require("mason").setup()

    -- Setup Mason with none-ls for automatic tool installation
    require("mason-null-ls").setup({
      ensure_installed = { "cspell" }, -- Automatically install cspell
      automatic_installation = true,
    })

    -- Load none-ls and cspell
    local none_ls = require("null-ls")
    local cspell = require("cspell")

    -- Define cspell configuration options
    local cspell_config = {
      --config_file_path = "~/.config/cspell/cspell.json",
      config_file_preferred_name = "cspell.json", -- Define preferred name for cspell config
      cspell_config_dirs = { "~/.config/cspell/", "~/.config/nvim/" }, -- Add custom directories for cspell config
      read_config_synchronously = false, -- Synchronous read to avoid delays
    }

    -- Setup none-ls with cspell diagnostics and code actions
    none_ls.setup({
      update_in_insert = false,
      sources = {
        cspell.diagnostics.with({
          config = cspell_config,
          -- generator_opts = {
          --   -- Override the diagnostics behavior to skip in insert mode
          --   on_output = function(params, done)
          --     local mode = vim.api.nvim_get_mode().mode
          --     if not _G.diagnostics_enabled then
          --       return done() -- No-op if in insert mode
          --     end
          --     -- Call the original on_output function
          --     return require("cspell.diagnostics.parser")(params, done)
          --   end,
          -- },
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
          end,
        }), -- Spell-check diagnostics as hints
        cspell.code_actions.with({
          config = cspell_config,
          method = none_ls.methods.CODE_ACTION,
        }),
      },
    })
  end,
}
