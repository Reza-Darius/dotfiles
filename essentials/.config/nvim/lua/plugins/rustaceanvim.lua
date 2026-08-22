-- plugins/rustaceanvim.lua
return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = false },
              closureCaptureHints = { enable = false },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" },
              parameterHints = { enable = false },
              typeHints = { enable = false },
              reborrowHints = { enable = "never" },
              renderColons = false,
            },
          },
        },
      },
    }
  end,
}
