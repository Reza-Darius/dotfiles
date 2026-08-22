return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      bind_to_cwd = true,
      window = {
        width = 28,
      },
    },
    window = {
      fuzzy_finder_mappings = {
        ["<C-j>"] = "move_cursor_down",
        ["<C-k>"] = "move_cursor_up",
      }
    }
  },
}
