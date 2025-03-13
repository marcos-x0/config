return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Configure custom diagnostic handler for clangd
      if not opts.servers then
        opts.servers = {}
      end
      if not opts.servers.clangd then
        opts.servers.clangd = {}
      end

      -- Add an LSP attach handler for clangd specifically
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            -- Create a custom handler that filters out the specific warning
            client.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ctx, config)
              -- Filter out the specific warning by code
              local filtered = {}
              for _, diag in ipairs(result.diagnostics) do
                -- Filter out the "invalid_token_after_toplevel_declarator" warning
                if not (diag.code == "invalid_token_after_toplevel_declarator") then
                  table.insert(filtered, diag)
                end
              end
              result.diagnostics = filtered

              -- Call the default handler with filtered diagnostics
              vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx, config)
            end, {})
          end
        end,
      })
    end,
  },
}
