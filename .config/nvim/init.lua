-- 16-color mode: draw with kitty's ANSI palette, which DMS regenerates
-- from the wallpaper, so nvim follows the desktop theme with no plugin.
vim.o.termguicolors = false

vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- Built-in autocompletion, setup from :h ins-autocompletion-example
vim.o.autocomplete = true
vim.o.complete = ".^5,w^5,b^5,u^5"
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })
