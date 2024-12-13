return {
  'neovim/nvim-lspconfig',
  opts = function(_, opts)
    -- local server_opts =
    opts.lua_ls = vim.tbl_deep_extend('force', opts.lua_ls or {}, {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
          diagnostics = {
            globals = { 'vim' }, -- Recognize 'vim' as a global
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true), -- Neovim runtime files
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
  end,
  --
  config = function()
    require('mason-tool-installer').setup {
      ensure_installed = { 'lua-language-server', 'stylua' }, -- Ensure Lua tools are installed
    }
  end,
}
