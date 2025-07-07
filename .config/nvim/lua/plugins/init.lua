-- [[ Install `lazy.nvim` plugin manager ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error("Error cloning lazy.nvim:\n" .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
-- To check the current status of your plugins, run
--   :Lazy
--
-- You can press `?` in this menu for help. Use `:q` to close the window
--
-- To update plugins you can run
--   :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
  -- Detect tabstop and shiftwidth automatically
  { "NMAC427/guess-indent.nvim", opts = {} },

  -- Import all plugin configurations
  { import = "plugins.telescope" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.treesitter" },
  { import = "plugins.ui" },
  { import = "plugins.formatting" },
  { import = "plugins.oil" },
  { import = "plugins.misc" },
  { import = "plugins.harpoon" },

  -- Import kickstart plugins
  require "kickstart.plugins.debug",
  require "kickstart.plugins.indent_line",
  require "kickstart.plugins.lint",
  require "kickstart.plugins.autopairs",
  require "kickstart.plugins.gitsigns",
  -- We're using oil instead for more simpler vim like approach to filetrees
  -- require('kickstart.plugins.neo-tree'),
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
