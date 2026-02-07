local tools = require "config.tools"

return {
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
      desc = "toggle [l]inting",
    },
  },
  config = function()
    local lint = require "lint"
    lint.linters_by_ft = tools.linters or {}

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        if vim.g.disable_lint then return end

        if vim.bo.modifiable then
          local filename = vim.api.nvim_buf_get_name(0)
          local is_deno_project = tools.is_deno_project(filename)

          if is_deno_project then
            local original_linters = lint.linters_by_ft
            lint.linters_by_ft = vim.tbl_deep_extend("force", original_linters, {
              javascript = {},
              typescript = {},
              javascriptreact = {},
              typescriptreact = {},
            })
            lint.try_lint()
            lint.linters_by_ft = original_linters
          else
            lint.try_lint()
          end
        end
      end,
    })
  end,
}
