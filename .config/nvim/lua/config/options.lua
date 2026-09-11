vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.termguicolors = true
opt.foldenable = false
opt.foldcolumn = "0"
opt.wrap = false
opt.scrolloff = 8
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- matches the [yaml]/[javascript]/[typescript] 2-space overrides in
-- .config/vscode.code-profile
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "yaml", "json", "javascript", "typescript", "javascriptreact", "typescriptreact" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})
