return {
  servers = {
    vtsls = {
      settings = {
        vtsls = {
          diagnostics = {
            enable = true,
          },
          telemetry = {
            enable = true,
          },
          formatting = {
            enable = true,
          },
          hover = {
            enable = true,
          },
          completion = {
            enable = true,
            autoImports = true,
            completeFunctionCalls = true,
          },
          inlayHints = {
            parameterNames = { enabled = 'all', suppressWhenArgumentMatchesName = true },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enable = true },
            enumMemberValues = { enabled = true },
          },
        },
      },
      on_attach = function(client, bufnr)
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.buf.inlay_hint(bufnr, true)
        end
      end,

      root_dir = require('lspconfig').util.root_pattern('vite.config.ts', 'vite.config.js', 'package.json'),
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
      single_file_support = true,
    },
  },
  ensure_installed = { 'vtsls' },
}
