return {
  'smjonas/inc-rename.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('inc_rename').setup {}
  end,
}
