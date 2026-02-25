local tools = require "config.tools"

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local lint = require "lint"
    lint.linters_by_ft = tools.linters or {}

    local cwd_by_ft = {
      php = function() return vim.fs.root(0, { "phpcs.xml", "phpcs.xml.dist" }) end,
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        if vim.g.disable_lint then return end

        if vim.bo.modifiable then
          local filename = vim.api.nvim_buf_get_name(0)
          local is_deno_project = tools.is_deno_project(filename)

          local cwd_fn = cwd_by_ft[vim.bo.filetype]
          local opts = cwd_fn and { cwd = cwd_fn() } or nil

          if is_deno_project then
            local original_linters = lint.linters_by_ft
            lint.linters_by_ft = vim.tbl_deep_extend("force", original_linters, {
              javascript = {},
              typescript = {},
              javascriptreact = {},
              typescriptreact = {},
            })
            lint.try_lint(nil, opts)
            lint.linters_by_ft = original_linters
          else
            lint.try_lint(nil, opts)
          end
        end
      end,
    })
  end,
}
