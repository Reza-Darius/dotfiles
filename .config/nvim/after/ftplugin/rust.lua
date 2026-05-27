local bufnr = vim.api.nvim_get_current_buf()

-- vim.keymap.set({ "n", "v" }, "<C-.>", function()
--   vim.cmd.RustLsp("codeAction")
-- end, { silent = true, buffer = bufnr, desc = "Rust code action" })

vim.keymap.set({ "n", "v", "i" }, "<C-.>", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" then
    vim.cmd("normal! \27")
    vim.cmd("'<,'>RustLsp codeAction")
  elseif mode == "i" then
    vim.cmd("stopinsert")
    vim.schedule(function()
      vim.cmd.RustLsp("codeAction")
    end)
  else
    vim.cmd.RustLsp("codeAction")
  end
end, { silent = true, buffer = bufnr, desc = "Rust code action" })

vim.keymap.set("n", "K", function()
  vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr, desc = "Rust hover actions" })
