
-- -- -- tokyonight_night config for Rust

return {
  "folke/tokyonight.nvim",
  opts = function(_, opts)
    opts.style = opts.style or "night"

    local user_on_highlights = opts.on_highlights

    opts.on_highlights = function(hl, c)
      if user_on_highlights then
        user_on_highlights(hl, c)
      end

      ---------------------------------------------------------------------
      -- Palette picks (tokyonight_night colors)
      ---------------------------------------------------------------------
      local purple = c.purple -- #9d7cd8  keywords
      local type_blue = c.blue1 -- #2ac3de  types (blue, not teal/green)
      local white = c.fg -- #c0caf5  proc-macros / args / vars
      local gold = c.yellow -- #e0af68  fn-like macros & traits
      local orange = c.orange -- #ff9e64  constants & literals
      local red = c.red -- #f7768e  self
      local light_blue = c.cyan -- #7dcfff  namespaces / modules
      local operator_color = c.blue5 -- #89ddff  operators incl. &
      -- local operator_color = c.fg     -- #89ddff  operators incl. &
      local func_blue = c.blue -- #7aa2f7  functions/methods

      ---------------------------------------------------------------------
      -- Treesitter captures (nvim-treesitter rust queries)
      ---------------------------------------------------------------------
      hl["@lsp.type.parameter.c"] = { fg = white }

      hl["@type.builtin.c"] = { fg = type_blue }
      hl["@lsp.typemod.class.defaultLibrary.c"] = { fg = type_blue }
      hl["@lsp.typemod.type.defaultLibrary.c"] = { fg = type_blue }

      hl["@lsp.typemod.function.defaultLibrary.c"] = { fg = func_blue }
    end
  end,
}
