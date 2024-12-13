return function(opts, lspconfig)
  -- Ensure Mason installs `deno`
  require('mason-tool-installer').setup {
    ensure_installed = { 'deno' },
  }

  -- Configure the `denols` LSP
  lspconfig.denols.setup(vim.tbl_deep_extend('force', opts, {
    settings = {
      deno = {
        enable = true, -- Enable the Deno LSP
        lint = true, -- Enable linting
        unstable = false, -- Enable unstable APIs
        suggest = {
          autoImports = true, -- Enable auto-import suggestions
          completeFunctionCalls = false, -- Enable function call completions
          names = true, -- Suggest variable and function names
        },
        inlayHints = {
          parameterNames = {
            enabled = 'literals', -- Show parameter names for literals (options: "none", "literals", "all")
          },
          variableTypes = true, -- Show inlay hints for variable types
          propertyDeclarationTypes = true, -- Show inlay hints for property declaration types
          functionLikeReturnTypes = true, -- Show return types for functions
          enumMemberValues = true, -- Show enum member values
        },
      },
    },
    root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    single_file_support = false, -- Disable single-file support
  }))
end
