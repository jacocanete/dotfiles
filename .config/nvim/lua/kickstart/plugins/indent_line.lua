return {
	{ -- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = "ibl",
		opts = {
			indent = {
				char = "│", -- Use vertical line instead of >>
				-- char = "┊",  -- Alternative: dotted line
				-- char = " ",  -- Alternative: invisible (just highlighting)
			},
			scope = {
				char = "│",
				show_start = false,
				show_end = false,
			},
		},
	},
}
