---@diagnostic disable: undefined-global
return {
  -- Fugitive: Git commands
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gwrite", "Gread", "Gvdiffsplit", "Gdiffsplit", "Gclog" },
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "FugitiveIndex",
        callback = function(event)
          local opts = { buffer = event.buf }

          local ai_commit_job = nil
          local ai_commit_request = nil

          vim.keymap.set("n", "C", function()
            if ai_commit_job then
              vim.fn.jobstop(ai_commit_job)
              ai_commit_job = nil
              ai_commit_request = nil
              Snacks.notifier.hide "ai_commit"
              Snacks.notify.warn("Cancelled", { title = "AI Commit" })
              return
            end

            if vim.fn.executable "curl" ~= 1 then
              Snacks.notify.error("curl not found in PATH", { title = "AI Commit" })
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

            local staged_diff = vim.fn.system "git diff --staged --stat; git diff --staged | head -2000"
            if vim.v.shell_error ~= 0 then
              Snacks.notify.error("Failed to read staged diff", { title = "AI Commit" })
              return
            end

            local prompt = "Generate a concise git commit message for these staged changes. Output ONLY the raw commit message with no markdown, no code blocks, no backticks, no explanations. Use conventional commit format.\n\n"
              .. staged_diff

            local request = {}
            ai_commit_request = request

            local server = "http://10.121.16.20:4096"
            local directory = vim.uri_encode(vim.fn.getcwd())
            local session_url = server .. "/session?directory=" .. directory

            local function fail(message)
              if ai_commit_request ~= request then return end

              ai_commit_job = nil
              ai_commit_request = nil
              Snacks.notifier.hide "ai_commit"
              Snacks.notify.error(message, { title = "AI Commit" })
            end

            local function post(url, body, callback)
              local output = {}

              ai_commit_job = vim.fn.jobstart({
                "curl",
                "-fsS",
                "-X",
                "POST",
                url,
                "-H",
                "Content-Type: application/json",
                "--data",
                body,
              }, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                  if data then vim.list_extend(output, data) end
                end,
                on_exit = function(_, exit_code)
                  if ai_commit_request ~= request then return end

                  ai_commit_job = nil
                  callback(exit_code, table.concat(output, "\n"))
                end,
              })

              if ai_commit_job <= 0 then fail "Failed to start curl" end
            end

            post(session_url, "{}", function(exit_code, response)
              if exit_code ~= 0 then
                fail "Failed to connect to OpenCode"
                return
              end

              local ok, session = pcall(vim.json.decode, response)
              if not ok or type(session) ~= "table" or type(session.id) ~= "string" then
                fail "Invalid response from OpenCode"
                return
              end

              local message_url = server .. "/session/" .. session.id .. "/message?directory=" .. directory
              local body = vim.json.encode {
                model = { providerID = "openai", modelID = "gpt-5.6-luna-fast" },
                parts = { { type = "text", text = prompt } },
              }

              post(message_url, body, function(message_exit_code, message_response)
                if message_exit_code ~= 0 then
                  fail "Failed to generate commit message"
                  return
                end

                local decoded, result = pcall(vim.json.decode, message_response)
                if not decoded or type(result) ~= "table" or type(result.parts) ~= "table" then
                  fail "Invalid response from OpenCode"
                  return
                end

                ai_commit_job = nil
                ai_commit_request = nil
                Snacks.notifier.hide "ai_commit"

                local commit_msg_lines = {}

                for _, part in ipairs(result.parts) do
                  if part.type == "text" and type(part.text) == "string" then
                    table.insert(commit_msg_lines, part.text)
                  end
                end

                local commit_msg = vim.trim(table.concat(commit_msg_lines, "\n"))
                if commit_msg == "" then
                  Snacks.notify.error("Empty response from OpenCode", { title = "AI Commit" })
                  return
                end

                vim.schedule(function()
                  local tmp = "/tmp/nvim_ai_commit_msg"
                  vim.fn.writefile(vim.split(commit_msg, "\n"), tmp)
                  Snacks.notify.info("Commit message ready!", { title = "AI Commit", timeout = 2000 })
                  vim.cmd("Git commit -e -F " .. tmp)
                end)
              end)
            end)
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
