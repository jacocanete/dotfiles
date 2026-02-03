return {
  "tpope/vim-fugitive",
  config = function()
    -- Only set up keymaps in Fugitive buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function(event)
        local opts = { buffer = event.buf }

        -- Register Fugitive keymaps with which-key for discoverability
        local wk = require("which-key")
        wk.add({
          { "s", desc = "Stage file/hunk", buffer = event.buf },
          { "u", desc = "Unstage file/hunk", buffer = event.buf },
          { "-", desc = "Toggle stage/unstage", buffer = event.buf },
          { "=", desc = "Toggle inline diff", buffer = event.buf },
          { "cc", desc = "Commit", buffer = event.buf },
          { "ca", desc = "Commit --amend", buffer = event.buf },
          { "ce", desc = "Commit --amend --no-edit", buffer = event.buf },
          { "cw", desc = "Commit --amend (reword only)", buffer = event.buf },
          { "C", desc = "AI commit message", buffer = event.buf },
          { "dd", desc = "Diff file", buffer = event.buf },
          { "dv", desc = "Diff file (vertical split)", buffer = event.buf },
          { "X", desc = "Discard change", buffer = event.buf },
          { "g?", desc = "Show all keybindings", buffer = event.buf },
        })

        -- AI-generated commit message (Shift+C)
        vim.keymap.set("n", "C", function()
          -- Check if there are staged changes
          vim.fn.system "git diff --cached --quiet"
          if vim.v.shell_error == 0 then
            vim.notify("No staged changes to commit", vim.log.levels.WARN)
            return
          end

          -- Generate commit message with Claude Code CLI
          local claude_cmd =
            [[git diff --staged | claude -p 'Generate a concise git commit message for these staged changes. Output ONLY the raw commit message with no markdown, no code blocks, no backticks, no explanations. Use conventional commit format.' --model haiku --output-format text --strict-mcp-config --mcp-config $HOME/.config/claude/mcp-empty.json]]

          local commit_msg = vim.fn.system(claude_cmd)

          if vim.v.shell_error ~= 0 then
            vim.notify("Failed to generate commit message", vim.log.levels.ERROR)
            return
          end

          -- Write to temp file and open commit buffer
          local tmp = "/tmp/nvim_ai_commit_msg"
          vim.fn.writefile(vim.split(commit_msg, "\n"), tmp)
          vim.cmd("Git commit -e -F " .. tmp)
        end, vim.tbl_extend("force", opts, { desc = "AI commit message" }))

        -- Quick keymaps for common operations
        vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", vim.tbl_extend("force", opts, { desc = "[G]it [P]ush" }))
        vim.keymap.set("n", "<leader>gP", "<cmd>Git pull<cr>", vim.tbl_extend("force", opts, { desc = "[G]it [P]ull" }))
      end,
    })

    -- Telescope git branches integration
    vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "[G]it [B]ranches" })
  end,
  keys = {
    { "<leader>gs", "<cmd>Git<cr>", desc = "[G]it [S]tatus" },
  },
}
