return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require "harpoon"

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set("n", "<leader>ma", function() harpoon:list():add() end, { desc = "marks [a]dd" })
    vim.keymap.set(
      "n",
      "<leader>mm",
      function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = "marks ho[m]e" }
    )

    vim.keymap.set("n", "<leader>m1", function() harpoon:list():select(1) end, { desc = "marks [1]" })
    vim.keymap.set("n", "<leader>m2", function() harpoon:list():select(2) end, { desc = "marks [2]" })
    vim.keymap.set("n", "<leader>m3", function() harpoon:list():select(3) end, { desc = "marks [3]" })
    vim.keymap.set("n", "<leader>m4", function() harpoon:list():select(4) end, { desc = "marks [4]" })
    vim.keymap.set("n", "<leader>m5", function() harpoon:list():select(5) end, { desc = "marks [5]" })

    vim.keymap.set("n", "<leader>mp", function() harpoon:list():prev() end, { desc = "marks [p]rev" })
    vim.keymap.set("n", "<leader>mn", function() harpoon:list():next() end, { desc = "marks [n]ext" })
  end,
}
