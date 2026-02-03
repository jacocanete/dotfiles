return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    vim.o.autoread = true

    vim.keymap.set(
      { "n", "x" },
      "<C-a>",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "[O]pencode [A]sk" }
    )
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "[O]pencode [S]elect" })
    vim.keymap.set(
      { "n", "t" },
      "<C-/>",
      function() require("opencode").toggle() end,
      { desc = "[O]pencode [T]erminal" }
    )

    vim.keymap.set(
      "n",
      "<S-C-u>",
      function() require("opencode").command "session.half.page.up" end,
      { desc = "Scroll opencode up" }
    )
    vim.keymap.set(
      "n",
      "<S-C-d>",
      function() require("opencode").command "session.half.page.down" end,
      { desc = "Scroll opencode down" }
    )

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
}
