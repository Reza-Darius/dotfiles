return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- opts.formatters.sqlfluff = {
    --   args = { "format", "--dialect=postgres", "-" },
    -- }
    opts.formatters.sqlfluff = {
      command = "sqlfluff",
      args = { "format", "-" },
      cwd = require("conform.util").root_file({ ".sqlfluff" }),
    }
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.markdown = { "prettier" }
    opts.formatters_by_ft.python = { "ruff" }
    opts.formatters_by_ft.bash = { "shfmt" }
    opts.formatters_by_ft.sh = { "shfmt" }
    opts.formatters_by_ft.sql = { "sqlfluff" }
  end,
}
