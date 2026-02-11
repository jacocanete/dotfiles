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

			local parser_for_filetype = {
				typescriptreact = "tsx",
				javascriptreact = "javascript",
				sh = "bash",
			}

			local filetypes = {}
			for _, lang in ipairs(tools.languages or {}) do
				filetypes[lang] = true
			end
			for ft, _ in pairs(parser_for_filetype) do
				filetypes[ft] = true
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(filetypes),
				callback = function(args)
					local ft = args.match
					local lang = parser_for_filetype[ft] or ft
					vim.treesitter.start(args.buf, lang)
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "php",
				callback = function(args)
					vim.schedule(function()
						vim.bo[args.buf].indentexpr = ""
						vim.bo[args.buf].autoindent = true
					end)
				end,
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
