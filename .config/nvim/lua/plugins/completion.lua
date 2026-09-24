return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
		},
		sources = {
			default = { "lsp", "path", "buffer" },
		},
	},
}
