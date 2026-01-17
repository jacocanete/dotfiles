-- Fuzzy Finder (files, lsp, etc)
return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- If encountering errors, see telescope-fzf-native README for installation instructions
        "nvim-telescope/telescope-fzf-native.nvim",

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = "make",

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function() return vim.fn.executable "make" == 1 end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require("telescope").setup {
        -- You can put your default mappings / updates / etc. in here
        -- All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          frecency = {
            show_scores = true,
            show_filter_column = false,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      -- See `:help telescope.builtin`
      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader>sc", builtin.git_bcommits, { desc = "[S]earch [C]ommits (file history)" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- It's also possible to pass additional configuration options.
      -- See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set(
        "n",
        "<leader>s/",
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          }
        end,
        { desc = "[S]earch [/] in Open Files" }
      )

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set(
        "n",
        "<leader>sn",
        function() builtin.find_files { cwd = vim.fn.stdpath "config" } end,
        { desc = "[S]earch [N]eovim files" }
      )

      -- Configure base directories to search for git repositories
      local git_base_folders = {
        vim.fn.expand "~/Projects",
      }

      -- Custom function to find git repositories in configured directories
      vim.keymap.set("n", "<leader>sp", function()
        local git_repos = {}
        local max_depth = 3

        -- Search each configured base directory
        for _, base_path in ipairs(git_base_folders) do
          if vim.fn.isdirectory(base_path) == 1 then
            local handle =
              io.popen('find "' .. base_path .. '" -maxdepth ' .. max_depth .. ' -type d -name ".git" 2>/dev/null')
            if handle then
              for line in handle:lines() do
                -- Get parent directory of .git folder
                local repo_path = vim.fn.fnamemodify(line, ":h")
                local repo_name = vim.fn.fnamemodify(repo_path, ":t")
                local base_name = vim.fn.fnamemodify(base_path, ":t")
                table.insert(git_repos, {
                  name = repo_name,
                  path = repo_path,
                  display = repo_name .. " (" .. base_name .. "/" .. repo_name .. ")",
                })
              end
              handle:close()
            end
          end
        end

        -- Use telescope to display the git repositories
        require("telescope.pickers")
          .new({}, {
            prompt_title = "Search Git Repositories",
            finder = require("telescope.finders").new_table {
              results = git_repos,
              entry_maker = function(entry)
                return {
                  value = entry.path,
                  display = entry.display,
                  ordinal = entry.name,
                }
              end,
            },
            sorter = require("telescope.config").values.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
              require("telescope.actions").select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                -- Change to the selected directory
                vim.cmd("cd " .. vim.fn.fnameescape(selection.value))
                print("Changed to: " .. selection.value)
              end)
              return true
            end,
          })
          :find()
      end, { desc = "[S]earch [P]rojects (Git Repositories)" })
    end,
  },
}
