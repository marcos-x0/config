return {
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  config = function()
    local nvim_lsp = require("lspconfig")
    nvim_lsp.nil_ls.setup({
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nixfmt" },
          },
        },
      },
    })
  end,
}
