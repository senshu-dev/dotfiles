return {
	"nvim-lualine/lualine.nvim",
	opts = function()
		local ok, theme = pcall(function()
			return require("lualine.themes._base46")("dms")
		end)
		return { options = { theme = ok and theme or "auto" } }
	end,
}
