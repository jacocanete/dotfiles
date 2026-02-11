return {
  -- Copilot: inline ghost text completions
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        copilot_node_command = vim.fn.expand "$HOME/.local/share/fnm/node-versions/v22.17.0/installation/bin/node",
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },

  -- Opencode: AI coding assistant
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      ---@module 'snacks'
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      vim.keymap.set(
        { "n", "x" },
        "<C-a>",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        { desc = "Opencode ask" }
      )
      vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Opencode select" })

      vim.keymap.set(
        { "n", "x" },
        "go",
        function() return require("opencode").operator "@this " end,
        { desc = "Add range to opencode", expr = true }
      )
      vim.keymap.set(
        "n",
        "goo",
        function() return require("opencode").operator "@this " .. "_" end,
        { desc = "Add line to opencode", expr = true }
      )
    end,
  },
}
