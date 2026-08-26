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

      --===================================================================
      -- Rust Config
      --===================================================================
      hl["@keyword.rust"] = { fg = purple }
      hl["@keyword.function.rust"] = { fg = purple }
      hl["@keyword.return.rust"] = { fg = purple }
      hl["@keyword.operator.rust"] = { fg = purple }
      hl["@keyword.import.rust"] = { fg = purple }
      hl["@keyword.storage.rust"] = { fg = purple } -- pub, const, static, mut
      hl["@keyword.modifier.rust"] = { fg = purple }
      hl["@keyword.type.rust"] = { fg = purple } -- struct / enum / trait / impl

      hl["@type.rust"] = { fg = type_blue }
      hl["@type.builtin.rust"] = { fg = type_blue }
      hl["@type.definition.rust"] = { fg = type_blue }

      -- Proc macro styling
      hl["@attribute.rust"] = { fg = white }
      hl["@lsp.type.decorator.rust"] = { fg = white }
      hl["@lsp.type.builtinAttribute.rust"] = { fg = white }
      hl["@lsp.type.derive.rust"] = { fg = gold }

      hl["@function.macro.rust"] = { fg = gold } -- format!, println!, vec!, ...
      hl["@function.macro.builtin.rust"] = { fg = gold } -- std/builtin macros specifically

      hl["@constant.rust"] = { fg = orange }
      hl["@constant.builtin.rust"] = { fg = orange }
      hl["@number.rust"] = { fg = orange }
      hl["@boolean.rust"] = { fg = orange }

      hl["@variable.builtin.rust"] = { fg = red } -- self

      hl["@namespace.rust"] = { fg = light_blue }
      hl["@module.rust"] = { fg = light_blue }

      hl["@operator.rust"] = { fg = operator_color } -- includes &
      hl["@punctuation.special.rust"] = { fg = operator_color }

      hl["@function.rust"] = { fg = func_blue }
      hl["@function.call.rust"] = { fg = func_blue }
      hl["@method.rust"] = { fg = func_blue }
      hl["@method.call.rust"] = { fg = func_blue }

      -- builtin / std-lib calls (size_of, u16::from_be, bytemuck::cast, ...)
      -- nvim-treesitter tags these separately from user-defined functions,
      -- which is why they weren't picking up the plain function/method
      -- rules above.
      hl["@function.builtin.rust"] = { fg = func_blue }
      hl["@function.builtin.call.rust"] = { fg = func_blue }
      hl["@method.builtin.rust"] = { fg = func_blue }
      hl["@method.builtin.call.rust"] = { fg = func_blue }

      hl["@variable.rust"] = { fg = white }
      hl["@variable.parameter.rust"] = { fg = white }

      ---------------------------------------------------------------------
      -- LSP semantic tokens (rust-analyzer), nvim 0.9+
      -- format: @lsp.type.<type>.rust  /  @lsp.typemod.<type>.<mod>.rust
      ---------------------------------------------------------------------
      hl["@lsp.type.keyword.rust"] = { fg = purple }

      hl["@lsp.type.struct.rust"] = { fg = type_blue }
      hl["@lsp.type.enum.rust"] = { fg = type_blue }
      hl["@lsp.type.union.rust"] = { fg = type_blue }
      hl["@lsp.type.type.rust"] = { fg = type_blue }
      hl["@lsp.type.typeAlias.rust"] = { fg = type_blue }
      hl["@lsp.type.builtinType.rust"] = { fg = type_blue }
      hl["@lsp.type.typeParameter.rust"] = { fg = type_blue }

      -- builtin/std types (Box, Vec, Option, String, ...) arrive as a
      -- combined type+modifier group (e.g. @lsp.typemod.struct.defaultLibrary.rust)
      -- which nvim renders at a HIGHER priority than the plain
      -- @lsp.type.struct.rust rule above, and which links to a generic
      -- (non-rust) @type.builtin group by default -- that's why builtins
      -- were showing a different, darker blue. Overriding the combined
      -- groups directly fixes it.
      hl["@lsp.typemod.struct.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.struct.library.rust"] = { fg = type_blue }
      hl["@lsp.typemod.enum.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.enum.library.rust"] = { fg = type_blue }
      hl["@lsp.typemod.union.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.union.library.rust"] = { fg = type_blue }
      hl["@lsp.typemod.type.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.type.library.rust"] = { fg = type_blue }
      hl["@lsp.typemod.typeAlias.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.builtinType.defaultLibrary.rust"] = { fg = type_blue }
      hl["@lsp.typemod.typeParameter.defaultLibrary.rust"] = { fg = type_blue }

      hl["@lsp.type.interface.rust"] = { fg = gold } -- traits (LSP-standard token name)
      hl["@lsp.type.trait.rust"] = { fg = gold } -- some rust-analyzer versions send this instead
      hl["@lsp.type.macro.rust"] = { fg = gold } -- declarative fn-like macros (format!, vec!)
      hl["@lsp.typemod.macro.defaultLibrary.rust"] = { fg = gold } -- builtin/std macros specifically
      hl["@lsp.type.deriveHelper.rust"] = { fg = white }
      hl["@lsp.type.attribute.rust"] = { fg = white } -- proc/attribute macros, #[derive(...)]
      hl["@lsp.type.attributeBracket.rust"] = { fg = white }
      -- some rust-analyzer versions send proc/attribute macros as type "macro"
      -- with an "attribute" modifier rather than as type "attribute" -- keep
      -- this white (proc macro) so it doesn't get swept up by the gold
      -- @lsp.type.macro.rust rule above.
      hl["@lsp.typemod.macro.attribute.rust"] = { fg = white }

      -- builtin / std-lib functions & methods via LSP defaultLibrary modifier
      hl["@lsp.typemod.function.defaultLibrary.rust"] = { fg = func_blue }
      hl["@lsp.typemod.method.defaultLibrary.rust"] = { fg = func_blue }

      hl["@lsp.type.enumMember.rust"] = { fg = orange }
      hl["@lsp.typemod.variable.constant.rust"] = { fg = orange }
      hl["@lsp.typemod.variable.static.rust"] = { fg = orange }

      hl["@lsp.type.selfKeyword.rust"] = { fg = red }
      hl["@lsp.type.selfTypeKeyword.rust"] = { fg = red }

      hl["@lsp.type.namespace.rust"] = { fg = white }
      hl["@lsp.type.crate.rust"] = { fg = white }

      -- struct fields: intentionally left unstyled -- inherits tokyonight's
      -- default color instead of a custom one.

      hl["@lsp.type.operator.rust"] = { fg = operator_color }

      hl["@lsp.type.function.rust"] = { fg = func_blue }
      hl["@lsp.type.method.rust"] = { fg = func_blue }

      hl["@lsp.type.parameter.rust"] = { fg = white }
      hl["@lsp.type.variable.rust"] = { fg = white }
      hl["@lsp.type.generic.rust"] = { fg = white }
      hl["@lsp.type.lifetime.rust"] = { fg = white }

      ---------------------------------------------------------------------
      -- Legacy regex syntax groups (runtime syntax/rust.vim)
      -- These are NOT namespaced per-language, but they only ever fire on
      -- rust buffers since they're rust-specific group names. Neovim falls
      -- back to these whenever treesitter/LSP semantic tokens aren't
      -- covering a token (e.g. :Inspect shows "rustStructure links to
      -- Keyword" instead of "@lsp.type.struct.rust" or "@type.rust").
      --
      -- IMPORTANT: this layer can only do keyword/regex-level distinctions.
      -- It cannot tell a struct field from a local variable, or a proc
      -- macro from a trait name -- that granularity only exists once
      -- treesitter + rust-analyzer semantic tokens are actually attached.
      -- See the note at the bottom of the chat message for how to check.
      ---------------------------------------------------------------------
      hl["rustKeyword"] = { fg = purple }
      hl["rustConditional"] = { fg = purple }
      hl["rustRepeat"] = { fg = purple }
      hl["rustStructure"] = { fg = purple } -- struct/enum/trait/impl/mod/union
      hl["rustStorage"] = { fg = purple } -- pub/const/static/mut/ref/move
      hl["rustTypedef"] = { fg = purple } -- the `type` keyword itself

      hl["rustType"] = { fg = type_blue }
      hl["rustPrimitiveType"] = { fg = type_blue }

      hl["rustTrait"] = { fg = gold }
      hl["rustDeriveTrait"] = { fg = white } -- names inside #[derive(...)]
      hl["rustMacro"] = { fg = gold } -- format!, println!, vec!, ...
      hl["rustAttribute"] = { fg = white } -- #[...] / #![...]

      hl["rustEnumVariant"] = { fg = orange }
      hl["rustConstant"] = { fg = orange }
      hl["rustNumber"] = { fg = orange }
      hl["rustBoolean"] = { fg = orange }

      hl["rustSelf"] = { fg = red }

      hl["rustModPath"] = { fg = light_blue }
      hl["rustModPathSep"] = { fg = light_blue }

      hl["rustSigil"] = { fg = operator_color } -- & and * (refs/derefs)
      hl["rustOperator"] = { fg = operator_color }

      hl["rustFuncName"] = { fg = func_blue }
      hl["rustFuncCall"] = { fg = func_blue }

      hl["rustIdentifier"] = { fg = white }

      --===================================================================
      -- C Config
      --===================================================================
      hl["@lsp.type.parameter.c"] = { fg = white }

      hl["@type.builtin.c"] = { fg = type_blue }
      hl["@lsp.typemod.class.defaultLibrary.c"] = { fg = type_blue }
      hl["@lsp.typemod.type.defaultLibrary.c"] = { fg = type_blue }

      hl["@lsp.typemod.function.defaultLibrary.c"] = { fg = func_blue }
    end
  end,
}
