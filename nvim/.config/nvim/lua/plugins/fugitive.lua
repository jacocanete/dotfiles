---@diagnostic disable: undefined-global
return {
  "tpope/vim-fugitive",
  config = function()
    -- Only set up keymaps in Fugitive buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function(event)
        local opts = { buffer = event.buf }

        -- AI-generated commit message (Shift+C)
        local ai_commit_job = nil

        vim.keymap.set("n", "C", function()
          -- Check if claude CLI is available
          if vim.fn.executable("claude") ~= 1 then
            Snacks.notify.error("Claude CLI not found in PATH", { title = "AI Commit" })
            return
          end

          -- Cancel existing job if running
          if ai_commit_job then
            vim.fn.jobstop(ai_commit_job)
            ai_commit_job = nil
            Snacks.notifier.hide "ai_commit"
            Snacks.notify.warn("Cancelled", { title = "AI Commit" })
            return
          end

          -- Check if there are staged changes
          vim.fn.system "git diff --cached --quiet"
          if vim.v.shell_error == 0 then
            Snacks.notify.warn("No staged changes to commit", { title = "AI Commit" })
            return
          end

          -- Spinner frames
          local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

          -- Show progress notification with spinner
          Snacks.notify.info("Generating commit message...", {
            id = "ai_commit",
            title = "AI Commit",
            timeout = false,
            opts = function(notif) notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1] end,
          })

          local claude_cmd =
            [[git diff --staged | claude -p 'Generate a concise git commit message for these staged changes. Output ONLY the raw commit message with no markdown, no code blocks, no backticks, no explanations. Use conventional commit format.' --model haiku --output-format text --strict-mcp-config --mcp-config $HOME/.config/claude/mcp-empty.json]]

          local output = {}

          ai_commit_job = vim.fn.jobstart(claude_cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then output = data end
            end,
            on_exit = function(_, exit_code)
              ai_commit_job = nil
              Snacks.notifier.hide "ai_commit"

              if exit_code ~= 0 then
                Snacks.notify.error("Failed to generate commit message", { title = "AI Commit" })
                return
              end

              local commit_msg = table.concat(output, "\n")
              if vim.trim(commit_msg) == "" then
                Snacks.notify.error("Empty response from Claude", { title = "AI Commit" })
                return
              end

              -- Write to temp file and open commit buffer (must be scheduled to main thread)
              vim.schedule(function()
                local tmp = "/tmp/nvim_ai_commit_msg"
                vim.fn.writefile(vim.split(commit_msg, "\n"), tmp)
                Snacks.notify.info("Commit message ready!", { title = "AI Commit", timeout = 2000 })
                vim.cmd("Git commit -e -F " .. tmp)
              end)
            end,
          })
        end, vim.tbl_extend("force", opts, { desc = "AI commit message" }))

        -- Quick keymaps for common operations (in fugitive buffer)
        vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", vim.tbl_extend("force", opts, { desc = "[G]it [P]ush" }))
        vim.keymap.set("n", "<leader>gP", "<cmd>Git pull<cr>", vim.tbl_extend("force", opts, { desc = "[G]it Pul[L]" }))
        vim.keymap.set(
          "n",
          "<leader>gf",
          "<cmd>Git fetch<cr>",
          vim.tbl_extend("force", opts, { desc = "[G]it [F]etch" })
        )
        vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", vim.tbl_extend("force", opts, { desc = "[G]it [L]og" }))
      end,
    })
  end,
  keys = {
    { "<leader>gs", "<cmd>Git<cr>", desc = "[G]it [S]tatus" },
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "[G]it [C]ommit" },
    { "<leader>gh", "<cmd>Git log -- %<cr>", desc = "[G]it [H]istory (file)" },
    { "<leader>gv", "<cmd>Gvdiffsplit<cr>", desc = "[G]it [V]ertical diff" },
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "[G]it [B]lame" },
    { "<leader>gw", "<cmd>Gwrite<cr>", desc = "[G]it [W]rite (stage file)" },
    { "<leader>gr", "<cmd>Gread<cr>", desc = "[G]it [R]ead (revert buffer)" },
    { "<leader>gd", "<cmd>Git diff %<cr>", desc = "[G]it [D]iff (file)" },
    { "<leader>gD", "<cmd>Git diff --staged %<cr>", desc = "[G]it [D]iff staged (file)" },
  },
}
