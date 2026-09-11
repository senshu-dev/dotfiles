return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
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

		vim.lsp.enable({
			"gopls",
			"terraformls",
			"pyright",
			"bashls",
			"yamlls",
			"dockerls",
			"helm_ls",
			"lua_ls",
			"clangd",
		})

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
		})
	end,
}
