return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("yamlls", {
			settings = {
				yaml = {
					schemaStore = { enable = true },
					keyOrdering = false,
				},
			},
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
				},
			},
		})

		-- Installs missing servers on startup; every mason-installed server
		-- is vim.lsp.enable()d automatically (automatic_enable default).
		require("mason-lspconfig").setup({
			ensure_installed = {
				"gopls",
				"terraformls",
				"pyright",
				"bashls",
				"yamlls",
				"dockerls",
				"helm_ls",
				"lua_ls",
				"clangd",
			},
		})

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
		})
	end,
}
