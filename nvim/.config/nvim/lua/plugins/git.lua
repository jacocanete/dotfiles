---@diagnostic disable: undefined-global
return {
  -- Fugitive: Git commands
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gwrite", "Gread", "Gvdiffsplit", "Gdiffsplit", "Gclog" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function(event)
          local opts = { buffer = event.buf }

          local ai_commit_job = nil

          vim.keymap.set("n", "C", function()
            if ai_commit_job then
              vim.fn.jobstop(ai_commit_job)
              ai_commit_job = nil
              Snacks.notifier.hide "ai_commit"
              Snacks.notify.warn("Cancelled", { title = "AI Commit" })
              return
            end

            if vim.fn.executable "claude" ~= 1 then
              Snacks.notify.error("Claude CLI not found in PATH", { title = "AI Commit" })
              return
            end

            vim.fn.system "git diff --cached --quiet"
            if vim.v.shell_error == 0 then
              Snacks.notify.warn("No staged changes to commit", { title = "AI Commit" })
              return
            end

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

            Snacks.notify.info("Generating commit message...", {
              id = "ai_commit",
              title = "AI Commit",
              timeout = false,
              opts = function(notif) notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1] end,
            })

            local claude_cmd =
              [[{ git diff --staged --stat; git diff --staged | head -2000; } | claude -p 'Generate a concise git commit message for these staged changes. Output ONLY the raw commit message with no markdown, no code blocks, no backticks, no explanations. Use conventional commit format.' --model haiku --output-format text --strict-mcp-config --mcp-config $HOME/.config/claude/mcp-empty.json]]

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

                vim.schedule(function()
                  local tmp = "/tmp/nvim_ai_commit_msg"
                  vim.fn.writefile(vim.split(commit_msg, "\n"), tmp)
                  Snacks.notify.info("Commit message ready!", { title = "AI Commit", timeout = 2000 })
                  vim.cmd("Git commit -e -F " .. tmp)
                end)
              end,
            })
          end, vim.tbl_extend("force", opts, { desc = "AI commit message" }))

          vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", vim.tbl_extend("force", opts, { desc = "git [p]ush" }))
          vim.keymap.set("n", "<leader>gP", "<cmd>Git pull<cr>", vim.tbl_extend("force", opts, { desc = "git [P]ull" }))
          vim.keymap.set(
            "n",
            "<leader>gf",
            "<cmd>Git fetch<cr>",
            vim.tbl_extend("force", opts, { desc = "git [f]etch" })
          )
          vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", vim.tbl_extend("force", opts, { desc = "git [l]og" }))
        end,
      })
    end,
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "git [s]tatus" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "git [c]ommit" },
      { "<leader>gh", "<cmd>Git log -- %<cr>", desc = "git [h]istory (file)" },
      { "<leader>gv", "<cmd>Gvdiffsplit<cr>", desc = "git [v]ertical diff" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "git [b]lame" },
      { "<leader>gw", "<cmd>Gwrite<cr>", desc = "git [w]rite (stage file)" },
      { "<leader>gr", "<cmd>Gread<cr>", desc = "git [r]ead (revert buffer)" },
      { "<leader>gd", "<cmd>Git diff %<cr>", desc = "git [d]iff (file)" },
      { "<leader>gD", "<cmd>Git diff --staged %<cr>", desc = "git [D]iff staged (file)" },
    },
  },

  -- Gitsigns: git signs in the gutter + hunk operations
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      attach_to_untracked = true,
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]g", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end, { desc = "Jump to next [g]it change" })

        map("n", "[g", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end, { desc = "Jump to previous [g]it change" })

        -- Actions (visual mode)
        map(
          "v",
          "<leader>hs",
          function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { desc = "git [s]tage hunk" }
        )
        map(
          "v",
          "<leader>hr",
          function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { desc = "git [r]eset hunk" }
        )

        -- Actions (normal mode)
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage/unstage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
        map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })

        -- Toggles (using Snacks toggle for consistent UI)
        Snacks.toggle({
          name = "Git Blame Line",
          get = function() return require("gitsigns.config").config.current_line_blame end,
          set = function() gitsigns.toggle_current_line_blame() end,
        }):map "<leader>tb"

        Snacks.toggle({
          name = "Git Show Deleted",
          get = function() return require("gitsigns.config").config.show_deleted end,
          set = function() gitsigns.toggle_deleted() end,
        }):map "<leader>tD"
      end,
    },
  },
}
