-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { silent = true })

vim.keymap.set("n", "i", function()
  return string.match(vim.api.nvim_get_current_line(), "%g") == nil and "cc" or "i"
end, { expr = true, noremap = true })

vim.keymap.set("n", "a", function()
  return string.match(vim.api.nvim_get_current_line(), "%g") == nil and "cc" or "a"
end, { expr = true, noremap = true })


vim.keymap.set("n", "<leader>dd", "<leader>xx", {remap = true})
vim.keymap.set("n", "<leader>dD", "<leader>xX", {remap = true})

-- rebinding notification window
vim.keymap.set("n", "<leader>dn", function()
  if Snacks.config.picker and Snacks.config.picker.enabled then
    Snacks.picker.notifications()
  else
    Snacks.notifier.show_history()
  end
end, { desc = "Notification History" })

-- clear all other buffer excpet the ones open in windows
vim.keymap.set("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })

  for _, buf in ipairs(bufs) do
    if buf.bufnr ~= current then
      local wins = vim.fn.win_findbuf(buf.bufnr)
      if #wins == 0 then
        vim.api.nvim_buf_delete(buf.bufnr, { force = false })
      end
    end
  end
end, { desc = "Close other buffers (keep visible ones)" })

local function alnum_forward()
  -- Move off any current alphanumeric chars (like w leaving the current word)
  vim.fn.search('[^A-Za-z0-9]', 'W')
  -- Then jump to the start of the next alphanumeric sequence
  vim.fn.search('[A-Za-z0-9]', 'W')
end

-- function for q button in normal mode
local function alnum_backward()
  -- Move off any current alphanumeric chars going back
  vim.fn.search('[^A-Za-z0-9]', 'bW')
  -- Then jump to the start of the previous alphanumeric sequence
  vim.fn.search('[A-Za-z0-9]', 'bW')
end
vim.keymap.set({'n', 'x', 'o'}, 'q', alnum_forward,  { desc = 'Next alphanumeric word' })
vim.keymap.set({'n', 'x', 'o'}, 'Q', alnum_backward, { desc = 'Prev alphanumeric word' })

vim.keymap.set("n", "r", "cl")
