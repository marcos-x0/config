return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Function to check if this is a Deno project
    local function is_deno_project()
      return vim.fn.findfile("deno.json", ".git/..;") ~= "" or vim.fn.findfile("deno.jsonc", ".git/..;") ~= ""
    end

    -- List of filetypes supported by both Deno and Prettier
    local deno_supported_filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "json",
      "jsonc",
    }

    -- Add logic for Deno-supported filetypes
    for _, ft in ipairs(deno_supported_filetypes) do
      opts.formatters_by_ft[ft] = function()
        if is_deno_project() then
          return { "deno_fmt" }
        else
          return { "prettier" }
        end
      end
    end

    return opts
  end,
}
