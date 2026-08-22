return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        -- disables flash for f, F, t, T
        enabled = false,
        keys = { "f", "F", "t", "T", [";"] = ",", [","] = ";" },
      },
    },
  },
}
