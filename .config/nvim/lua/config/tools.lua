-- lua/config/tools.lua
return {
	-- Formatters (used by conform.nvim)
	formatters = {
		lua = { "stylua" },
		php = { "phpcbf" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescriptreact = { "eslint_d" },
		json = { "prettier" },
		markdown = { "markdownlint" },
		sh = { "shfmt" },
		-- Conform can also run multiple formatters sequentially
		-- python = { "isort", "black" },
		--
		-- You can use 'stop_after_first' to run the first available formatter from the list
		-- javascript = { "prettierd", "prettier", stop_after_first = true },
	},

	-- Linters (used by nvim-lint)
	linters = {
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescriptreact = { "eslint_d" },
		php = { "phpcs" },
		json = { "jsonlint" },
		markdown = { "markdownlint" },
	},

	-- LSP Servers (used by lsp.lua)
	-- Can list server configs here too
	servers = {
		-- clangd = {},
		-- gopls = {},
		-- pyright = {},
		-- rust_analyzer = {},
		-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
		--
		-- Some languages (like typescript) have entire language plugins that can be useful:
		--    https://github.com/pmizio/typescript-tools.nvim
		--
		-- But for many setups, the LSP (`ts_ls`) will work just fine
		-- ts_ls = {},

		intelephense = {
			filetypes = {
				"php",
			},
			-- root_dir = function(fname)
			-- 	local util = require("lspconfig.util")
			--
			-- 	-- Check if we're inside wp-content (themes, plugins, etc.)
			-- 	if string.find(fname, "/wp-content/") then
			-- 		-- Extract the site root (~/Local Sites/[wp-theme]/)
			-- 		local site_root = string.match(fname, "(.*/Local Sites/[^/]+)")
			-- 		if site_root then
			-- 			return site_root
			-- 		end
			-- 	end -- Fall back to default root detection
			-- 	local git_root = vim.fs.find(".git", { path = fname, upward = true })[1]
			-- 	return util.root_pattern("composer.json", ".git", "wp-config.php")(fname)
			-- 		or (git_root and vim.fs.dirname(git_root))
			-- 		or vim.fs.dirname(fname)
			-- end,
			settings = {
				intelephense = {
					files = {
						maxSize = 5000000,
					},
					stubs = {
						"Core",
						"wordpress",
						"pcre",
						"fileinfo",
						"standard",
						"json",
						"date",
					},
					environment = {
						includePaths = {
							vim.fn.expand("~/.composer/vendor/php-stubs/"),
						},
					},
				},
			},
		},
		-- cssls = {
		--   capabilities = {
		--     documentFormattingProvider = false,
		--     documentRangeFormattingProvider = false,
		--   },
		--   settings = {
		--     css = {
		--       validate = true,
		--       lint = {
		--         unknownAtRules = 'ignore',
		--       },
		--     },
		--     scss = {
		--       validate = false,
		--       lint = {
		--         unknownAtRules = 'ignore',
		--       },
		--     },
		--   },
		-- },
		somesass_ls = {
			capabilities = {
				documentFormattingProvider = false,
				documentRangeFormattingProvider = false,
			},
			filetypes = { "scss", "sass" },
		},
		stylelint_lsp = {
			settings = {
				stylelintplus = {
					autoFixOnSave = true,
				},
			},
			filetypes = { "css", "scss" },
		},
		emmet_language_server = {
			filetypes = {
				"css",
				"html",
				"javascript",
				"javascriptreact",
				"scss",
				"typescript",
				"typescriptreact",
				"php",
			},
		},
		lua_ls = {
			-- cmd = { ... },
			-- filetypes = { ... },
			-- capabilities = {},
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
					diagnostics = { disable = { "missing-fields" } },
				},
			},
		},
	},

	-- Additional tools (linters, debuggers, etc.)
	-- List tools here that aren't automatically installed
	-- Tools that are automatically installed are the ones from tools.lsp, tools.linters, and tools.formatters
	additional_tools = {
		"typescript-language-server",
	},

	-- Languages (used by nvim-treesitter)
	languages = {
		"bash",
		"c",
		"diff",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
		"tsx",
		"typescript",
		"css",
		"scss",
		"php",
	},
}
