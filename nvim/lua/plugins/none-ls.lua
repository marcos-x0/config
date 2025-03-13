return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "davidmh/cspell.nvim",
    "jay-babu/mason-null-ls.nvim",
  },
  config = function()
    -- Setup Mason
    require("mason").setup()

    -- Setup Mason with none-ls for automatic tool installation
    require("mason-null-ls").setup({
      ensure_installed = { "cspell" }, -- Automatically install cspell
      automatic_installation = true,
    })

    local null_ls = require("null-ls")
    local cspell = require("cspell")
    local cspell_config = {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity["HINT"] -- ERROR, WARN, INFO, HINT
      end,
      config = {
        find_json = function(_)
          return vim.fn.expand("~/.config/nvim/cspell.json")
        end,
        on_success = function(cspell_config_file_path, params, action_name)
          if action_name == "add_to_json" then
            os.execute(
              string.format(
                "cat %s | jq -S '.words |= sort' | tee %s > /dev/null",
                cspell_config_file_path,
                cspell_config_file_path
              )
            )
          end
        end,
      },
    }

    null_ls.setup({
      sources = {
        cspell.diagnostics.with(cspell_config),
        cspell.code_actions.with(cspell_config),
      },
      -- handlers = handlers,
      -- on_attach = on_attach,
    })
  end,
}
