local pick = function()
  -- Use Telescope for refactoring options
  local telescope = require 'telescope'
  telescope.extensions.refactoring.refactors()
end

return {
  {
    'ThePrimeagen/refactoring.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim', -- Telescope dependency
    },
    keys = {
      { '<leader>r', '', desc = '+refactor', mode = { 'n', 'v' } },
      {
        '<leader>rs',
        pick,
        mode = 'v',
        desc = 'Refactor',
      },
      {
        '<leader>ri',
        function()
          require('refactoring').refactor 'Inline Variable'
        end,
        mode = { 'n', 'v' },
        desc = 'Inline Variable',
      },
      {
        '<leader>rb',
        function()
          require('refactoring').refactor 'Extract Block'
        end,
        desc = 'Extract Block',
      },
      {
        '<leader>rf',
        function()
          require('refactoring').refactor 'Extract Block To File'
        end,
        desc = 'Extract Block To File',
      },
      {
        '<leader>rP',
        function()
          require('refactoring').debug.printf { below = false }
        end,
        desc = 'Debug Print',
      },
      {
        '<leader>rp',
        function()
          require('refactoring').debug.print_var { normal = true }
        end,
        desc = 'Debug Print Variable',
      },
      {
        '<leader>rc',
        function()
          require('refactoring').debug.cleanup {}
        end,
        desc = 'Debug Cleanup',
      },
      {
        '<leader>rf',
        function()
          require('refactoring').refactor 'Extract Function'
        end,
        mode = 'v',
        desc = 'Extract Function',
      },
      {
        '<leader>rF',
        function()
          require('refactoring').refactor 'Extract Function To File'
        end,
        mode = 'v',
        desc = 'Extract Function To File',
      },
      {
        '<leader>rx',
        function()
          require('refactoring').refactor 'Extract Variable'
        end,
        mode = 'v',
        desc = 'Extract Variable',
      },
    },
    opts = {
      prompt_func_return_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      prompt_func_param_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      printf_statements = {},
      print_var_statements = {},
      show_success_message = true, -- Show a message on successful refactoring
    },
    config = function(_, opts)
      require('refactoring').setup(opts)

      -- Load Telescope refactoring extension
      local telescope_ok, telescope = pcall(require, 'telescope')
      if telescope_ok then
        telescope.load_extension 'refactoring'
      end
    end,
  },
}
