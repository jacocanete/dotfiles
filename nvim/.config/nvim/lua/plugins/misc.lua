-- Collection of various small independent plugins/modules
return {
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup { n_lines = 5000 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      -- Simple and easy statusline.
      -- You could remove this setup call if you don't like it,
      -- and try some other statusline plugin
      local statusline = require "mini.statusline"
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return "%2l:%-2v" end

      -- Add custom section for format/lint status warnings
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_diagnostics = function()
        local warnings = {}
        if vim.g.disable_autoformat then
          table.insert(warnings, "FMT")
        end
        if vim.g.disable_lint then
          table.insert(warnings, "LINT")
        end
        if #warnings > 0 then
          return "⚠ " .. table.concat(warnings, " ")
        end
        return ""
      end

      -- ... and there is more!
      -- Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  -- Undo tree
  {
    "mbbill/undotree",
    lazy = false, -- needs to be explicitly set, because of the keys property
    keys = {
      {
        "<leader>tu",
        vim.cmd.UndotreeToggle,
        desc = "[T]oggle [u]ndotree",
      },
    },
  },

  -- Flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = true,
          highlight = {
            backdrop = true,
          },
        },
      },
    },
    keys = {
      {
        "zu",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter {
            jump = { pos = "start" },
            label = { before = true, after = false, style = "overlay" },
          }
        end,
        desc = "[zu] Flash Treesitter start",
      },
      {
        "zU",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter {
            jump = { pos = "end" },
            label = { before = true, after = false, style = "overlay" },
          }
        end,
        desc = "[zU] Flash Treesitter end",
      },
      {
        "r",
        mode = "o",
        function() end,
        desc = "Disabled",
      },
      {
        "R",
        mode = { "o", "x" },
        function() end,
        desc = "Disabled",
      },
      -- Turns off flash search
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- Hardtime
  -- {
  --   "m4xshen/hardtime.nvim",
  --   lazy = false,
  --   dependencies = { "MunifTanjim/nui.nvim" },
  --   opts = {},
  -- },
}
