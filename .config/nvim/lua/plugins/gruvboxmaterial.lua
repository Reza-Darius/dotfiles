return {
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000,
  config = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("gruvbox_material_custom", {}),
      pattern = "gruvbox-material",
      callback = function()
        local config = vim.fn["gruvbox_material#get_configuration"]()
        local p = vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
        local hl = vim.fn["gruvbox_material#highlight"]

        -- general config
        hl("@constant", p.purple, p.none)
        hl("@constant.builtin", p.purple, p.none)
        hl("@operator", p.orange, p.none)
        hl("@type", p.blue, p.none)
        hl("@type.builtin", p.blue, p.none)
        hl("@type.definition", p.blue, p.none)
        hl("@variable.member", p.fg1, p.none)
        hl("@variable", p.fg1, p.none)
        hl("@property", p.fg1, p.none)
        hl("@module", p.fg1, p.none)
        hl("@namespace", p.fg1, p.none)
        hl("@string", p.aqua, p.none)

        -- Rust specific config
        hl("@keyword.operator.rust", p.red, p.none)
        hl("@constant.rust", p.fg1, p.none)
        hl("@constant.builtin.rust", p.fg1, p.none)
        hl("@function.macro.rust", p.yellow, p.none)
        hl("@attribute.rust", p.yellow, p.none)

        -- LSP color config
        hl("@lsp.type.interface.rust", p.yellow, p.none)
        hl("@lsp.type.macro.rust", p.yellow, p.none)
        hl("@lsp.type.derive.rust", p.yellow, p.none)
        hl("@lsp.type.const.rust", p.purple, p.none)
        hl("@lsp.type.lifetime.rust", p.yellow, p.none)
        vim.api.nvim_set_hl(0, "@lsp.type.struct.rust", { link = "@type" })
        vim.api.nvim_set_hl(0, "@lsp.type.enum.rust", { link = "@type" })
        vim.api.nvim_set_hl(0, "@lsp.type.builtinType.rust", { link = "@type" })
        vim.api.nvim_set_hl(0, "@lsp.type.typeParameter", { link = "@type" })
        vim.api.nvim_set_hl(0, "@lsp.type.typeAlias", { link = "@type" })
        hl("@Fg", p.fg1, p.none)
        vim.api.nvim_set_hl(0, "@lsp.type.enumMember.rust", { link = "@Fg" })
        vim.api.nvim_set_hl(0, "@lsp.type.namespace.rust", { link = "@Fg" })
        vim.api.nvim_set_hl(0, "@lsp.type.property.rust", { link = "@Fg" })
        vim.api.nvim_set_hl(0, "@lsp.type.decorator.rust", { link = "@Fg" })
        -- vim.api.nvim_set_hl(0, "@function.macro", { link = "@Fg" })
        vim.api.nvim_set_hl(0, "@punctuation.special.rust", { link = "@Fg" })

        -- -- disable LSP highlighting
        -- for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        --   vim.api.nvim_set_hl(0, group, {})
        -- end

        -- GO config
        hl("@constant.builtin.go", p.purple, p.none)
        hl("@lsp.type.namespace.go", p.fg1, p.none)
        hl("@lsp.type.type.go", p.blue, p.none)
      end,
    })

    vim.g.gruvbox_material_disable_italic_comment = true
    vim.g.gruvbox_material_enable_italic = false
    -- vim.g.gruvbox_material_background = "hard"
    -- vim.g.gruvbox_material_ui_contrast = "high"
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    vim.g.gruvbox_material_diagnostic_line_highlight = true
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
