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
  end,
}
