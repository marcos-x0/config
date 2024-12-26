return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    opts.defaults.formatter = "path.filename_first"

    opts.winopts.preview.vertical = "up:50%"
    opts.winopts.preview.layout = "vertical"

    return opts
  end,
}
