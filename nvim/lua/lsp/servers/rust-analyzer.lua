return {
  servers = {
    rust_analyzer = {
      settings = {
        ['rust-analyzer'] = {
          assist = {
            importGranularity = 'module',
            importPrefix = 'by_crate',
          },
          cargo = {
            allFeatures = true,
          },
          checkOnSave = {
            command = 'clippy',
          },
          inlayHints = {
            lifetimeElisionHints = {
              enable = true,
              useParameterNames = true,
            },
            parameterHints = true,
            typeHints = true,
          },
        },
      },
    },
  },
  ensure_installed = { 'rustfmt' },
}
