-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- switch buffers
map("n", "<TAB>", ":BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })

-- Command --
-- allow saving of files as sudo when not opened using sudo
map("c", "w!!", "w !sudo tee > /dev/null %")
