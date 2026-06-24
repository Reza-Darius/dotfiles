return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "prettier" },
      python = { "ruff" },
      bash = { "shfmt" },
      sh = { "shfmt" },
    },
  },
}
