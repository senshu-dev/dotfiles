return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
	},
	keys = {
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
		{ "<leader>dc", function() require("dap").continue() end, desc = "Debug: continue/start" },
		{ "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
		{ "<leader>do", function() require("dap").step_over() end, desc = "Debug: step over" },
		{ "<leader>dO", function() require("dap").step_out() end, desc = "Debug: step out" },
		{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
		{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()
		require("dap-go").setup()
		require("dap-python").setup("/usr/bin/python3")

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Bash debugging has no mason.nvim-installed "bash-debug-adapter"
		-- on this host (this repo never uses mason - see lsp.lua), so it's
		-- wired by hand against the AUR vscode-bash-debug package, which
		-- drives the bashdb CLI.
		dap.adapters.sh = {
			type = "executable",
			command = "vscode-bash-debug",
			args = {},
		}
		dap.configurations.sh = {
			{
				type = "sh",
				request = "launch",
				name = "Launch bash script",
				program = "${file}",
				cwd = "${workspaceFolder}",
				pathBashdb = vim.fn.exepath("bashdb"),
				pathBash = "/bin/bash",
				pathCat = "cat",
				pathMkfifo = "mkfifo",
				pathPkill = "pkill",
				args = {},
				env = {},
				terminalKind = "integrated",
			},
		}
	end,
}
