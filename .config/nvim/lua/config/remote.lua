local M = {}

local function ssh_hosts()
	local hosts = {}
	local config_path = vim.fn.expand("~/.ssh/config")
	local f = io.open(config_path, "r")
	if not f then
		return hosts
	end
	for line in f:lines() do
		local host = line:match("^%s*Host%s+(%S+)$")
		if host and host ~= "*" then
			table.insert(hosts, host)
		end
	end
	f:close()
	return hosts
end

function M.mount()
	local hosts = ssh_hosts()
	vim.ui.select(hosts, { prompt = "SSH host (from ~/.ssh/config):" }, function(host)
		if not host then
			return
		end
		vim.ui.input({ prompt = "Remote path: ", default = "/" }, function(remote_path)
			if not remote_path or remote_path == "" then
				return
			end
			local mountpoint = vim.fn.expand("~/mnt/" .. host)
			vim.fn.mkdir(mountpoint, "p")
			local cmd = { "sshfs", host .. ":" .. remote_path, mountpoint }
			local result = vim.system(cmd, { text = true }):wait()
			if result.code ~= 0 then
				vim.notify("sshfs mount failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
				return
			end
			vim.cmd.cd(mountpoint)
			vim.notify("Mounted " .. host .. ":" .. remote_path .. " at " .. mountpoint)
		end)
	end)
end

vim.api.nvim_create_user_command("SshfsMount", M.mount, {})

return M
