return {
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
  --

  intelephense = {
    filetypes = {
      'php',
    },
    settings = {
      intelephense = {
        files = {
          5000000,
        },
        stubs = {
          'Core',
          'wordpress',
          'pcre',
          'fileinfo',
          'standard',
        },
        environment = {
          includePaths = {
            vim.fn.expand '~/.composer/vendor/php-stubs/',
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
    filetypes = { 'scss', 'sass' },
  },
  stylelint_lsp = {
    settings = {
      stylelintplus = {
        autoFixOnSave = true,
      },
    },
    filetypes = { 'css', 'scss' },
  },
  emmet_language_server = {
    filetypes = {
      'css',
      'html',
      'javascript',
      'javascriptreact',
      'scss',
      'typescript',
      'typescriptreact',
      'php',
    },
  },
  lua_ls = {
    -- cmd = { ... },
    -- filetypes = { ... },
    -- capabilities = {},
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
}
