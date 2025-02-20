return {
  "danymat/neogen",
  keys = {
    { "<leader>cdf", "<cmd>Neogen func<CR>", desc = "Generate Function Doc" },
    { "<leader>cdc", "<cmd>Neogen class<CR>", desc = "Generate Class Doc" },
  },
  config = function()
    require("neogen").setup({
      enabled = true,
      snippet_engine = "luasnip",
      -- input_after_comment = false,

      placeholders_text = {
        description = "-", -- Correctly places description at the top
        parameter = "-", -- Ensures param descriptions are formatted properly
        ["return"] = "any", -- Ensures @returns is correctly formatted
      },

      languages = {
        javascript = {
          template = {
            annotation_convention = "jsdoc",
            position = function(node, type)
              if type == "func" then
                local row, _ = node:start()
                return row, 0
              end
              return nil -- Default behavior for other types
            end,
          },
        },
        javascriptreact = {
          template = {
            annotation_convention = "jsdoc",
            position = function(node, type)
              if type == "func" then
                local row, _ = node:start()
                return row, 0
              end
              return nil -- Default behavior for other types
            end,
          },
        },
        typescript = {
          template = {
            annotation_convention = "tsdoc",
            position = function(node, type)
              if type == "func" then
                local row, _ = node:start()
                return row, 0
              end
              return nil -- Default behavior for other types
            end,
          },
        },
        typescriptreact = {
          template = {
            annotation_convention = "tsdoc",
            position = function(node, type)
              if type == "func" then
                local row, _ = node:start()
                return row, 0
              end
              return nil -- Default behavior for other types
            end,
          },
        },
      },
    })
  end,
  -- Uncomment next line if you want to follow only stable versions
  version = "*",
}
