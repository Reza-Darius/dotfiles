return {
  "nvim-mini/mini.pairs",
  opts = function(_, opts)
    -- Disable ' autopair in Rust buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        -- Map ' to just insert itself (buffer-local, overrides the global pair mapping)
        vim.keymap.set("i", "'", "'", { buffer = true })
      end,
    })
    return opts
  end,
}
