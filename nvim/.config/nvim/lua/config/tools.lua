-- lua/config/tools.lua

local function is_deno_project(bufnr) return vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) end

return {
  -- Utility functions
  is_deno_project = is_deno_project,

  -- Formatters (used by conform.nvim)
  formatters = {
    lua = { "stylua" },
    php = { "phpcbf" },
    javascript = { "prettier", "eslint_d" },
    typescript = { "prettier", "eslint_d" },
    javascriptreact = { "prettier", "eslint_d" },
    typescriptreact = { "prettier", "eslint_d" },
    json = { "prettier" },
    -- markdown = { "markdownlint" },
    sh = { "shfmt" },
    -- Conform can also run multiple formatters sequentially
    python = { "isort", "black" },
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
    denols = {
      root_dir = function(bufnr, on_dir)
        local root = is_deno_project(bufnr)
        if root then on_dir(root) end
      end,
      single_file_support = false,
    },
    ts_ls = {
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      root_dir = function(bufnr, on_dir)
        if is_deno_project(bufnr) then return end
        local root = vim.fs.root(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", ".git" })
        if root then on_dir(root) end
      end,
      single_file_support = false,
      capabilities = {
        documentFormattingProvider = true,
        documentRangeFormattingProvider = true,
      },
    },
    intelephense = {
      filetypes = {
        "php",
      },
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
            "hash",
            "standard",
            "json",
            "SPL",
            "date",
            "random",
            "Reflection",
          },
          environment = {
            includePaths = {
              vim.fn.expand "~/.composer/vendor/php-stubs/",
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
      settings = {
        somesass = {
          workspace = {
            loadPaths = { ".", "src/css" },
          },
        },
      },
    },
    stylelint_lsp = {
      settings = {
        stylelintplus = {
          autoFixOnSave = true,
        },
      },
      filetypes = { "css", "scss" },
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, { "package.json", ".git" })
        if root then on_dir(root) end
      end,
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
    -- Java Language Server
    jdtls = {},
    -- Python Language Server
    pylsp = {
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = { enabled = false },
            mccabe = { enabled = false },
            pyflakes = { enabled = false },
            flake8 = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            pylint = { enabled = false },
            -- Enable rope for refactoring
            rope_completion = { enabled = true },
            rope_autoimport = { enabled = true },
          },
        },
      },
    },
  },

  -- Mason package names for LSP servers
  -- These are the Mason registry names (not lspconfig names)
  -- Run :Mason to see available packages
  mason_servers = {
    "deno",
    "typescript-language-server",
    "intelephense",
    "some-sass-language-server",
    "stylelint-lsp",
    "emmet-language-server",
    "lua-language-server",
    "jdtls",
    "python-lsp-server",
  },

  -- Additional tools (formatters, linters, debuggers, etc.)
  additional_tools = {},

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
    "python",
    "regex",
  },
}
