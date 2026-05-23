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
        -- Rust specific config
        hl("@lsp.type.interface.rust", p.yellow, p.none)
        hl("@lsp.type.macro.rust", p.yellow, p.none)
        hl("@lsp.type.derive.rust", p.yellow, p.none)
        hl("@lsp.type.const.rust", p.purple, p.none)
        hl("@lsp.type.lifetime.rust", p.yellow, p.none)
        hl("@keyword.operator.rust", p.red, p.none)
        hl("@operator.rust", p.orange, p.none)
        hl("@type", p.blue, p.none)
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
        vim.api.nvim_set_hl(0, "@function.macro", { link = "@Fg" })
        vim.api.nvim_set_hl(0, "@punctuation.special.rust", { link = "@Fg" })
      end,
    })

    vim.g.gruvbox_material_disable_italic_comment = true
    vim.g.gruvbox_material_enable_italic = false
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_ui_contrast = "high"
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    vim.g.gruvbox_material_diagnostic_line_highlight = true
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
