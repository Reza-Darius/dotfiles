-- Config for trouble (diagnostic window)
return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      diagnostics = {
        win = {
          position = "right",
          size = 0.4,
        },
      },
    },
  },
}
