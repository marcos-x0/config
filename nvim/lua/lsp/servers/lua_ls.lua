return {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          hint = {
            enable = true, -- Enable inlay hints
            arrayIndex = 'Disable', -- Options: 'Enable', 'Auto', 'Disable'
            await = true,
            paramName = 'All', -- Options: 'All', 'Literal', 'Disable'
            paramType = true,
            semicolon = 'Disable', -- Options: 'All', 'SameLine', 'Disable'
            setType = true,
          },
          completion = { callSnippet = 'Replace' },
          diagnostics = { globals = { 'vim' } },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    },
  },
  ensure_installed = { 'stylua' },
}
