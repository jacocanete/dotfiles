-- Autoformat
local tools = require "config.tools"

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format { async = true, lsp_format = "fallback" }
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
    {
      "<leader>tf",
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        if vim.g.disable_autoformat then
          vim.notify("Autoformat disabled", vim.log.levels.INFO)
        else
          vim.notify("Autoformat enabled", vim.log.levels.INFO)
        end
      end,
      mode = "",
      desc = "[T]oggle auto[F]ormat",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Check if formatting is globally disabled
      if vim.g.disable_autoformat then
        return nil
      end

      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end

      local filename = vim.api.nvim_buf_get_name(bufnr)
      local is_deno_project = tools.is_deno_project(filename)

      -- Use different formatters for Deno projects
      if is_deno_project then
        local ft = vim.bo[bufnr].filetype
        if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
          return {
            timeout_ms = 1000,
            formatters = { "deno_fmt" },
          }
        end
      end

      return {
        timeout_ms = 1000,
        lsp_format = "fallback",
      }
    end,
    formatters_by_ft = tools.formatters or {},
  },
}
