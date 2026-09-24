local map = vim.keymap.set

-- Claude CLI toggle-terminal: just shells out to `claude` if it's on
-- $PATH. Never installs anything - a missing binary shows the normal
-- shell "command not found", no special-casing.
map("n", "<leader>rt", function()
	vim.cmd.vsplit()
	vim.cmd.terminal("claude")
	vim.cmd.startinsert()
end, { desc = "Toggle Claude CLI terminal" })

map("n", "<leader>rm", function()
	require("config.remote").mount()
end, { desc = "Mount remote host via sshfs" })

map("n", "<F2>", vim.lsp.buf.rename, { desc = "LSP rename" })
