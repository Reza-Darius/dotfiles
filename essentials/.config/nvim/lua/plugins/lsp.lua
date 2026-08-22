return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      zls = {
        settings = {
          zls = {
            enable_build_on_save = true,
            build_on_save_step = "check",
          },
        },
      },
    },
  },
}
