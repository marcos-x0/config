return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()

    -- Optional: Disable virtual text diagnostics to avoid duplicate display
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = true,
    })
  end,
}
