return {
  {
    'echasnovski/mini.nvim',
    version = '*', -- Use the latest stable version
    config = function()
      -- Setup only `mini.comment` with dynamic commentstring
      require('mini.comment').setup {
        options = {
          custom_commentstring = function()
            return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
          end,
        },
      }

      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      require('mini.pairs').setup()
      -- the idea of move is nice, but it doesnt do what is expected.
      -- can just dd the block and move  to the proper place and past there

      -- Setup `mini.move` with directional arrow keys
      -- require('mini.move').setup {
      --   mappings = {
      --     left = '<M-Left>',
      --     right = '<M-Right>',
      --     down = '<M-Down>',
      --     up = '<M-Up>',
      --   },
      -- }
    end,
  },

  -- Add `nvim-ts-context-commentstring` for dynamic commentstring
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true, -- Load only when necessary
    opts = {
      enable_autocmd = false, -- Disable automatic updates
    },
  },
}
