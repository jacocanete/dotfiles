local tools = require "config.tools"

return {

  { -- Linting
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>tl",
        function()
          vim.g.disable_lint = not vim.g.disable_lint
          if vim.g.disable_lint then
            vim.notify("Linting disabled", vim.log.levels.INFO)
            vim.diagnostic.reset()
          else
            vim.notify("Linting enabled", vim.log.levels.INFO)
            require("lint").try_lint()
          end
        end,
        desc = "[T]oggle [L]inting",
      },
    },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = tools.linters or {}


      vim.diagnostic.config {
        virtual_text = {
          source = true,
        },
        float = {
          source = true,
        },
      }
      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Check if linting is globally disabled
          if vim.g.disable_lint then
            return
          end

          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            local filename = vim.api.nvim_buf_get_name(0)
            local is_deno_project = tools.is_deno_project(filename)

            -- Skip eslint_d for Deno projects
            if is_deno_project then
              local original_linters = lint.linters_by_ft
              lint.linters_by_ft = vim.tbl_deep_extend("force", original_linters, {
                javascript = {},
                typescript = {},
                javascriptreact = {},
                typescriptreact = {},
              })
              lint.try_lint()
              lint.linters_by_ft = original_linters -- Restore original config
            else
              lint.try_lint()
            end
          end
        end,
      })
    end,
  },
}
