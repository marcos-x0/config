return {
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Check if nil_ls is part of the server configurations
    if opts.servers and opts.servers.nil_ls then
      -- Extend the existing configuration for nil_ls
      opts.servers.nil_ls.settings = vim.tbl_deep_extend("force", opts.servers.nil_ls.settings or {}, {
        ["nil"] = {
          formatting = {
            command = { "nixfmt" },
          },
        },
      })
    else
      -- If nil_ls is not configured, you can add it
      opts.servers = opts.servers or {}
      opts.servers.nil_ls = {
        settings = {
          ["nil"] = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      }
    end
  end,
}
