---@diagnostic disable: undefined-global
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = { ui_select = true },
    notifier = { enabled = true },
    input = { enabled = true },
    renamer = { enabled = true },
  },
  keys = {
    -- Search
    { "<leader>sh", function() Snacks.picker.help() end, desc = "search [h]elp" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "search [k]eymaps" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "search [f]iles" },
    { "<leader>ss", function() Snacks.picker() end, desc = "search [s]nacks pickers" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "search current [w]ord", mode = { "n", "x" } },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "search by [g]rep" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "search [d]iagnostics" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "search [r]esume" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "search [.] Recent Files" },
    { "<leader>sc", function() Snacks.picker.git_log_file() end, desc = "search [c]ommits (file)" },
    { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "[ ] Find buffers" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "[/] Fuzzily search in buffer" },
    { "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "search [/] in open files" },
    {
      "<leader>sn",
      function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end,
      desc = "search [n]eovim files",
    },
    -- Git
    { "<leader>sb", function() Snacks.picker.git_branches() end, desc = "search git [b]ranches" },
    -- Notifications
    { "<leader>sN", function() Snacks.notifier.show_history() end, desc = "search [N]otifications" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss all [n]otifications" },
  },
}
