-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    -- This runs whenever an LSP attaches to a buffer
    -- All LSP features will still work, we just modify the diagnostics display
    vim.diagnostic.config({
      virtual_text = false, -- Disable text at end of line
      virtual_lines = true,
      -- signs = true,             -- Keep the signs in the gutter
      -- underline = true,         -- Keep underlining the problems
      -- update_in_insert = false,
      -- severity_sort = true,
    })
  end,
})
