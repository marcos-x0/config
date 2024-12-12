return {
  'echasnovski/mini.nvim',
  version = '*', -- Use the latest stable version
  config = function()
    -- Setup only `mini.comment` for now
    require('mini.comment').setup()
    -- You can configure other modules here in the future, e.g.,
    -- require('mini.surround').setup()
    -- require('mini.pairs').setup()
    -- Add modules incrementally as needed

    require('mini.files').setup {
      mappings = {
        go_in = '<Right>',
        go_in_plus = '<CR>',
        go_out = '<Left>',
        go_out_plus = '<BS>',
        reset = '~',
      },

      windows = {
        preview = true,
        width_preview = 50,
      },
    }
    vim.keymap.set('n', '-', require('mini.files').open, { desc = 'Open parent directory' })
  end,
}
