return {
  servers = {
    vtsls = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      settings = {
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = 'always' },
          suggest = {
            completeFunctionCalls = true,
          },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = 'literals' },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
      root_dir = require('lspconfig').util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json'),
      commands = {
        GoToSourceDefinition = {
          function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf.execute_command {
              command = 'typescript.goToSourceDefinition',
              arguments = { params.textDocument.uri, params.position },
            }
          end,
          description = 'Go to source definition',
        },
        FindAllFileReferences = {
          function()
            vim.lsp.buf.execute_command {
              command = 'typescript.findAllFileReferences',
              arguments = { vim.uri_from_bufnr(0) },
            }
          end,
          description = 'Find all file references',
        },
        SelectTSVersion = {
          function()
            vim.lsp.buf.execute_command { command = 'typescript.selectTypeScriptVersion' }
          end,
          description = 'Select TypeScript workspace version',
        },
      },
      single_file_support = true,
      on_attach = function(client, bufnr)
        -- Check for `deno.json` or `deno.jsonc` in the root directory
        local util = require 'lspconfig.util'
        local root_dir = util.root_pattern('deno.json', 'deno.jsonc')(vim.fn.expand '%:p')

        if client.name == 'vtsls' and root_dir then
          -- Stop `vtsls` if a Deno project is detected
          client.stop()
          print 'Stopped vtsls due to presence of deno.json/deno.jsonc'
          return
        end

        -- Custom key mappings
        local map = vim.api.nvim_buf_set_keymap
        local opts = { noremap = true, silent = true }

        map(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        map(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        map(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        map(bufnr, 'n', '<leader>co', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        map(bufnr, 'n', '<leader>cu', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      end,
    },
  },
  ensure_installed = { 'vtsls' }, -- Ensure `vtsls` is installed via Mason
}
