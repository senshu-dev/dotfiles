local ok = pcall(vim.cmd.colorscheme, "dms")
if not ok then
	vim.cmd.colorscheme("habamax")
end
