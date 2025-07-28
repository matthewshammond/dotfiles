-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local ok, theme = pcall(require, "config.theme")
if ok and theme then
  vim.cmd.colorscheme(theme)
end
