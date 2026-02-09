return {
  -- Mini.nvim: textobjects, surround
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      local ai = require("mini.ai")
      ai.setup {
        n_lines = 5000,
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          b = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
        },
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()
    end,
  },

  -- Flash: jump anywhere
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
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- Undotree: undo history visualizer
  {
    "mbbill/undotree",
    lazy = false,
    keys = {
      {
        "<leader>tu",
        vim.cmd.UndotreeToggle,
        desc = "toggle [u]ndotree",
      },
    },
  },

  -- Autopairs: auto-close brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Guess-indent: detect tabstop and shiftwidth automatically
  { "NMAC427/guess-indent.nvim", opts = {} },
}
