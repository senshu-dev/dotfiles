vim.filetype.add({ extension = { ino = "cpp" } })

local M = {}

local function installed_cores()
	local result = vim.system({ "arduino-cli", "core", "list", "--json" }, { text = true }):wait()
	if result.code ~= 0 then
		return {}
	end
	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok or not decoded then
		return {}
	end
	local cores = {}
	for _, entry in ipairs(decoded.platforms or decoded) do
		table.insert(cores, entry.id)
	end
	return cores
end

local function ensure_core(fqbn, callback)
	local platform = fqbn:match("^([^:]+:[^:]+)")
	local cores = installed_cores()
	if vim.tbl_contains(cores, platform) then
		callback()
		return
	end
	vim.ui.select({ "yes", "no" }, {
		prompt = ("Board core '%s' not installed. Install it now?"):format(platform),
	}, function(choice)
		if choice ~= "yes" then
			return
		end
		vim.notify("Installing " .. platform .. "...")
		local result = vim.system({ "arduino-cli", "core", "install", platform }, { text = true }):wait()
		if result.code ~= 0 then
			vim.notify("Core install failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
			return
		end
		callback()
	end)
end

local function compile_db(dir, fqbn)
	local result = vim.system(
		{ "arduino-cli", "compile", "--fqbn", fqbn, "--only-compilation-database" },
		{ text = true, cwd = dir }
	):wait()
	if result.code ~= 0 then
		vim.notify("compile-database failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
		return false
	end
	return true
end

function M.init(name)
	if not name or name == "" then
		vim.notify("Usage: :ArduinoInit <sketch-name>", vim.log.levels.ERROR)
		return
	end
	vim.ui.input({ prompt = "Board FQBN (e.g. esp32:esp32:esp32): " }, function(fqbn)
		if not fqbn or fqbn == "" then
			return
		end
		ensure_core(fqbn, function()
			local result = vim.system({ "arduino-cli", "sketch", "new", name }, { text = true }):wait()
			if result.code ~= 0 then
				vim.notify("sketch new failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
				return
			end
			local sketch_dir = vim.fn.getcwd() .. "/" .. name
			if compile_db(sketch_dir, fqbn) then
				local marker = io.open(sketch_dir .. "/.fqbn", "w")
				if marker then
					marker:write(fqbn)
					marker:close()
				end
				vim.notify("Arduino sketch ready: " .. sketch_dir)
				vim.cmd.edit(sketch_dir .. "/" .. name .. ".ino")
			end
		end)
	end)
end

function M.regen()
	local dir = vim.fn.getcwd()
	local marker = io.open(dir .. "/.fqbn", "r")
	if not marker then
		vim.notify(".fqbn not found in " .. dir .. " - run :ArduinoInit first", vim.log.levels.ERROR)
		return
	end
	local fqbn = marker:read("*a")
	marker:close()
	if compile_db(dir, fqbn) then
		vim.notify("compile_commands.json regenerated")
	end
end

vim.api.nvim_create_user_command("ArduinoInit", function(args)
	M.init(args.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("ArduinoRegen", M.regen, {})

return M
