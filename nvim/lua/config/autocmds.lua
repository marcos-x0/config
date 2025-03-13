-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.lsp.inlay_hint.enable(false)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.lsp.inlay_hint.enable(true)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "fish",
  callback = function()
    vim.lsp.start({
      name = "fish-lsp",
      cmd = { "fish-lsp", "start" },
      cmd_env = { fish_lsp_show_client_popups = false },
    })
  end,
})
