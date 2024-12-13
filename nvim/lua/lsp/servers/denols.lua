return {
  servers = {
    denols = {
      settings = {
        deno = {
          enable = true, -- Enable the Deno language server
          lint = true, -- Enable linting
          unstable = false, -- Enable support for unstable APIs
          suggest = {
            autoImports = true, -- Enable auto-import suggestions
            completeFunctionCalls = false, -- Enable function call completions
            names = true, -- Suggest variable and function names
          },

          inlayHints = {
            parameterNames = { enabled = 'all', suppressWhenArgumentMatchesName = true },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = false, suppressWhenTypeMatchesName = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enable = true },
            enumMemberValues = { enabled = true },
          },
        },
      },
      root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
      filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      single_file_support = false, -- Only attach in projects with deno.json or deno.jsonc
    },
  },
  ensure_installed = { 'deno' }, -- Ensure `deno` is installed via Mason
}
