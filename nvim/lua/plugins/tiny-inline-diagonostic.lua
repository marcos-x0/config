return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy", -- Or `LspAttach`
  priority = 1000, -- needs to be loaded in first
  config = function()
    -- vim.diagnostic.config({
    --   virtual_text = false,
    --   signs = true, -- or false, depending on your preference
    --   underline = true, -- optional, customize as needed
    --   update_in_insert = false, -- optional
    -- })
    require("tiny-inline-diagnostic").setup({
      options = {
        throttle = 2000,
        show_source = true,
        multilines = true,
        show_all_diags_on_cursorline = true,
        enable_on_insert = true,
      },
    })
  end,
}
