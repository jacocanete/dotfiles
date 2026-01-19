# Jaco's Neovim Configuration

A highly customized Neovim configuration built upon kickstart.nvim,
featuring modern LSP support, intelligent completion, and a carefully
curated set of plugins for an enhanced development experience.

## 🚀 Features

- **Modern LSP**: Full language server protocol support with auto-installation
- **Intelligent Completion**: Blink.cmp with AI-powered suggestions via Supermaven
- **Fuzzy Finding**: Telescope with project management and git repository search
- **File Management**: Oil.nvim for vim-like file operations
- **Navigation**: Harpoon for quick file switching and Flash for enhanced movement
- **Development Tools**: Integrated formatting, linting, and debugging
- **UI Enhancements**: Tokyo Night theme with custom statusline and which-key hints

## 📦 Plugin Overview

### Core Plugins

#### 🔍 **Telescope** (`nvim-telescope/telescope.nvim`)

- Fuzzy finder for files, buffers, grep, and more
- Enhanced with FZF native sorting and UI select integration
- Custom project search across `~/Local Sites` and `~/Projects`
- **Key bindings**: `<leader>sf` (files), `<leader>sg` (grep), `<leader>sp` (projects)

#### 🧠 **LSP Configuration** (`neovim/nvim-lspconfig`)

- Language servers: TypeScript/JavaScript, PHP (Intelephense), Lua, CSS/SCSS, Deno
- Auto-installation via Mason
- Intelligent root detection for Deno vs Node.js projects
- **Key bindings**: `grn` (rename), `gra` (code action), `grd` (definition)

#### ⚡ **Completion** (`saghen/blink.cmp`)

- Modern completion engine with snippet support
- AI-powered suggestions via Supermaven integration
- LuaSnip for snippet expansion
- **Key bindings**: `<C-y>` (accept), `<C-space>` (trigger/docs)

#### 🎨 **UI & Theme**

- **Tokyo Night** theme with custom styling
- **Which-key** for keybinding hints
- **Todo Comments** for enhanced TODO/FIXME highlighting
- **Colorizer** for CSS color previews
- **Mini.nvim** modules for statusline and text objects

### Navigation & Movement

#### 🎯 **Harpoon** (`ThePrimeagen/harpoon`)

- Quick file switching and project navigation
- **Key bindings**: `<leader>ha` (add), `<leader>hh` (menu), `<leader>h1-4` (select)

#### ⚡ **Flash** (`folke/flash.nvim`)

- Enhanced movement with treesitter integration
- **Key bindings**: `zu` (treesitter start), `zU` (treesitter end), `<C-s>` (toggle)

#### 📁 **Oil** (`stevearc/oil.nvim`)

- File manager with vim-like operations
- Direct file editing interface
- Hidden files visible by default

### Development Tools

#### 🔧 **Formatting** (`stevearc/conform.nvim`)

- Auto-formatting on save for multiple languages
- Configured formatters: Stylua, ESLint, Prettier, PHP-CBF
- Deno project detection with `deno fmt`
- **Key bindings**: `<leader>f` (format buffer)

#### 📝 **Treesitter** (`nvim-treesitter/nvim-treesitter`)

- Syntax highlighting and code understanding
- Text objects for functions, classes, and blocks
- Context display for current scope
- **Languages**: Bash, C, HTML, Lua, TypeScript, CSS, SCSS, PHP, Markdown

#### 🛠️ **Linting** (via `nvim-lint`)

- Real-time linting for JavaScript, TypeScript, PHP, JSON, Markdown
- Configured linters: ESLint, PHPCS, JSONLint, Markdownlint

#### 🐛 **Debugging** (DAP integration)

- Debug Adapter Protocol support
- Go debugging with `nvim-dap-go`
- UI for debugging sessions

### Utility Plugins

#### 🔄 **Undo Tree** (`mbbill/undotree`)

- Visual undo history navigation
- **Key bindings**: `<leader>tu` (toggle)

#### 🔒 **Hardtime** (`m4xshen/hardtime.nvim`)

- Helps break bad vim habits
- Prevents excessive key repetition

#### 🎯 **Mini.nvim** (`echasnovski/mini.nvim`)

- **AI**: Better text objects (functions, classes, etc.)
- **Surround**: Add/delete/replace surroundings
- **Statusline**: Clean, informative status bar

## 🛠️ Language Support

### Supported Languages & Tools

| Language | LSP Server | Formatter | Linter | Debugger |
|----------|------------|-----------|---------|----------|
| **TypeScript/JavaScript** | ts_ls | ESLint | ESLint | ✓ |
| **Deno** | denols | deno fmt | - | - |
| **PHP** | Intelephense | PHP-CBF | PHPCS | - |
| **Lua** | lua_ls | Stylua | - | - |
| **CSS/SCSS** | stylelint_lsp, somesass_ls | - | Stylelint | - |
| **HTML** | emmet_language_server | - | - | - |
| **JSON** | - | Prettier | JSONLint | - |
| **Markdown** | - | Markdownlint | Markdownlint | - |
| **Bash** | - | shfmt | - | - |
| **Go** | - | - | - | ✓ |

## ⌨️ Key Bindings

### Core Navigation

- `<leader><leader>` - Find buffers
- `<leader>/` - Search in current buffer
- `<leader>sn` - Search Neovim config files

### LSP Functions

- `grn` - Rename symbol
- `gra` - Code action
- `grd` - Go to definition
- `grr` - Find references
- `gri` - Go to implementation
- `grt` - Go to type definition
- `gO` - Document symbols
- `gW` - Workspace symbols

### File Operations

- `<leader>f` - Format buffer
- `<leader>sf` - Search files
- `<leader>sg` - Live grep
- `<leader>sp` - Search projects

### Utility

- `<leader>tu` - Toggle undo tree
- `<leader>th` - Toggle inlay hints
- `<leader>ha` - Harpoon add file
- `<leader>hh` - Harpoon menu

## 🔧 Configuration Structure

```bash
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/             # Core configuration
│   │   ├── init.lua        # Main config loader
│   │   ├── keymaps.lua     # Key mappings
│   │   ├── options.lua     # Vim options
│   │   ├── autocmds.lua    # Auto commands
│   │   └── tools.lua       # LSP/tool configurations
│   ├── plugins/            # Plugin configurations
│   │   ├── init.lua        # Plugin loader
│   │   ├── lsp.lua         # LSP setup
│   │   ├── completion.lua  # Completion config
│   │   ├── telescope.lua   # Telescope setup
│   │   ├── ui.lua          # UI plugins
│   │   ├── treesitter.lua  # Treesitter config
│   │   ├── formatting.lua  # Formatting setup
│   │   ├── harpoon.lua     # Harpoon config
│   │   ├── oil.lua         # File manager
│   │   └── misc.lua        # Utility plugins
│   └── kickstart/          # Kickstart plugins
│       └── plugins/        # Additional kickstart modules
└── README.md               # This file
```

## 🚀 Installation

### Prerequisites

- Neovim 0.10+ (stable or nightly)
- Git
- Make
- C compiler (gcc/clang)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd-find](https://github.com/sharkdp/fd)
- Node.js (for TypeScript support)
- PHP (for PHP development)
- [Nerd Font](https://www.nerdfonts.com/) (recommended)

### Setup

1. **Backup existing config** (if any):

   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:

   ```bash
   git clone https://github.com/jacocanete/dotfiles.git ~/dotfiles
   ln -s ~/dotfiles/.config/nvim ~/.config/nvim
   ```

3. **Start Neovim**:

   ```bash
   nvim
   ```

4. **Install plugins**: Lazy.nvim will automatically install plugins on first run.

5. **Install language servers**: Run `:Mason` to verify LSP installation.

### Post-Installation

- Run `:checkhealth` to verify everything is working
- Configure your preferred theme variant in `lua/plugins/ui.lua`
- Customize keybindings in `lua/config/keymaps.lua`
- Add language servers in `lua/config/tools.lua`

## 🎨 Customization

### Adding New Languages

1. Add LSP server to `lua/config/tools.lua`:

   ```lua
   servers = {
     your_language_server = {
       -- server configuration
     }
   }
   ```

2. Add formatter/linter if needed:

   ```lua
   formatters = {
     your_language = { "formatter_name" }
   }
   ```

3. Add treesitter parser:

   ```lua
   languages = {
     "your_language"
   }
   ```

### Changing Theme

Edit `lua/plugins/ui.lua` to use different Tokyo Night variants:

- `tokyonight-night` (default)
- `tokyonight-storm`
- `tokyonight-day`
- `tokyonight-moon`

### Project Search Customization

Edit the `git_base_folders` in `lua/plugins/telescope.lua`:

```lua
local git_base_folders = {
  vim.fn.expand "~/your/project/path",
  vim.fn.expand "~/another/path",
}
```

## 🤝 Contributing

This configuration is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
Feel free to fork and customize to your needs.

## 📚 Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [Lua Guide for Neovim](https://neovim.io/doc/user/lua-guide.html)

---

*Happy coding! 🎉*

