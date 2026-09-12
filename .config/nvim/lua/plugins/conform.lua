return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	opts = {
		formatters_by_ft = {
			go = { "gofmt" },
			python = { "ruff_format" },
			sh = { "shfmt" },
			terraform = { "terraform_fmt" },
			tf = { "terraform_fmt" },
		},
		format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
	},
}
