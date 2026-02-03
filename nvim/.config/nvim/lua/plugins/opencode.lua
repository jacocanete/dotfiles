return {
  "NickvanDyke/opencode.nvim",
  config = function()
    vim.o.autoread = true

    vim.keymap.set(
      { "n", "x" },
      "<leader>oa",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "[O]pencode [A]sk" }
    )

    vim.keymap.set(
      { "n", "x" },
      "<leader>os",
      function() require("opencode").select() end,
      { desc = "[O]pencode [S]elect" }
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
