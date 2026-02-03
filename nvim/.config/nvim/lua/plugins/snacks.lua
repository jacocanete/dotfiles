---@diagnostic disable: undefined-global
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = { ui_select = true },
    notifier = { enabled = true },
    input = { enabled = true },
  },
  keys = {
    -- Search
    { "<leader>sh", function() Snacks.picker.help() end, desc = "[S]earch [H]elp" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "[S]earch [K]eymaps" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "[S]earch [F]iles" },
    { "<leader>ss", function() Snacks.picker() end, desc = "[S]earch [S]nacks pickers" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "[S]earch current [W]ord", mode = { "n", "x" } },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "[S]earch by [G]rep" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "[S]earch [D]iagnostics" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "[S]earch [R]esume" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "[S]earch Recent Files" },
    { "<leader>sc", function() Snacks.picker.git_log_file() end, desc = "[S]earch [C]ommits (file)" },
    { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "[ ] Find buffers" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "[/] Fuzzily search in buffer" },
    { "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "[S]earch [/] in open files" },
    {
      "<leader>sn",
      function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end,
      desc = "[S]earch [N]eovim files",
    },
    -- Git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "[G]it [B]ranches" },
    -- Notifications
    { "<leader>sN", function() Snacks.notifier.show_history() end, desc = "[S]earch [N]otifications" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss all notifications" },
  },
}
