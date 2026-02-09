-- Highlight, edit, and navigate code

local tools = require("config.tools")

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		},
		config = function()
			require("nvim-treesitter").install(tools.languages or {})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = tools.languages or {},
				callback = function() vim.treesitter.start() end,
			})
		end,
	},

	{
		-- Auto close/rename HTML & JSX tags
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},

	{
		-- Show sticky context at top of buffer
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			enable = true,
			max_lines = 3,
		},
	},
}
