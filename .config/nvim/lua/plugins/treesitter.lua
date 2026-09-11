return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"go",
			"hcl",
			"python",
			"bash",
			"yaml",
			"dockerfile",
			"helm",
			"lua",
			"markdown",
			"cpp",
		},
		highlight = { enable = true },
		indent = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
