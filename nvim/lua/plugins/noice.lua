return {
  "folke/noice.nvim",
  opts = function(_, opts)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      callback = function()
        local filename = vim.fn.expand("%") -- Get the current file's name
        require("noice").notify(string.format("%s", filename), "info", { title = "Saved" })
      end,
    })

    opts.presets.lsp_doc_border = true
  end,
}
