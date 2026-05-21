local bufnr = vim.api.nvim_get_current_buf()

-- vim.keymap.set({ "n", "v" }, "<C-.>", function()
--   vim.cmd.RustLsp("codeAction")
-- end, { silent = true, buffer = bufnr, desc = "Rust code action" })
vim.keymap.set({ "n", "v" }, "<C-.>", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" then
    -- force exit visual mode first so '< and '> marks are set correctly
    vim.cmd("normal! \27") -- escape
    vim.cmd("'<,'>RustLsp codeAction")
  else
    vim.cmd.RustLsp("codeAction")
  end
end, { silent = true, buffer = bufnr, desc = "Rust code action" })

vim.keymap.set("n", "K", function()
  vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr, desc = "Rust hover actions" })
