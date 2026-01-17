# Jaco's Dotfiles

A comprehensive dotfiles repository containing configurations for a modern Linux development environment focused on terminal-based workflows, web development, and productivity.

## Overview

This repository includes configurations for shell environments (Bash/Zsh), terminal emulators, text editors, version control, and various development tools. The setup emphasizes a cohesive experience across tools with consistent theming (Tokyo Night) and efficient keybindings.

## 📦 Included Applications & Tools

### 🖥️ Terminal & Shell

#### **Kitty** (`.config/kitty/`)
Modern GPU-accelerated terminal emulator with rich feature support.

**Features:**
- Theme: Tokyo Night
- Font: JetBrainsMono Nerd Font (14pt)
- Window padding: 10px
- Background opacity: 0.95
- No window decorations (borderless)
- Audio bell disabled
- Custom shift+enter keybinding

#### **Zellij** (`.config/zellij/`)
Rust-based terminal multiplexer with modern features and workspace management.

**Features:**
- Theme: Tokyo Night Night
- Default mode: Locked (prevents accidental command interception)
- Vim-style keybindings (hjkl navigation)
- Custom keybindings for pane, tab, and window management
- Kitty keyboard protocol disabled for compatibility
- Auto-start enabled via `.zshrc`
- Tab name auto-updates based on git repository/directory

**Key Modes:**
- `Ctrl+g`: Toggle locked mode
- `p`: Pane management mode
- `t`: Tab management mode
- `r`: Resize mode
- `m`: Move pane mode
- `s`: Scroll mode
- `o`: Session management mode

#### **Zsh** (`.zshrc`)
Z shell configuration with Oh My Zsh framework.

**Features:**
- Framework: Oh My Zsh
- Theme: Robbyrussell
- Plugins: wp-cli, git, zsh-autosuggestions, history
- Editor: Neovim
- FZF integration with keybindings
- Zoxide (smart cd replacement)
- Yazi file manager integration (Ctrl+E to launch)
- FNM (Fast Node Manager) auto-setup
- Custom Zellij tab naming on directory change
- Docker host configuration

**Aliases:**
- `sail`: Laravel Sail shortcut
- `xampp`: XAMPP manager launcher
- `y`: Yazi file manager with directory jumping

**Environment Variables:**
- `LOCALSITES`: ~/Local Sites
- `PROJECTS`: ~/Projects
- `EDITOR`: nvim
- `XDG_CONFIG_HOME`: ~/.config

**Tool Integrations:**
- SDKMAN for Java/JVM tools
- Deno runtime
- Bun JavaScript runtime
- Cargo (Rust) binaries
- CUDA toolkit
- Wine with Esync/Fsync enabled
- OpenCode

#### **Bash** (`.bashrc`)
Bash shell configuration for compatibility.

**Features:**
- FNM integration
- Zoxide integration
- FZF keybinding (Ctrl+F)
- Custom Git-aware prompt with branch display
- Laravel Sail alias
- Vulkan ICD configuration for NVIDIA
- SDKMAN integration

### ✏️ Editor

#### **Neovim** (`.config/nvim/`)
Highly customized Neovim setup built on kickstart.nvim.

**Full details available in:** [.config/nvim/README.md](.config/nvim/README.md)

**Key Features:**
- Modern LSP support (TypeScript, PHP, Lua, CSS/SCSS, Deno, HTML)
- Blink.cmp completion with Supermaven AI integration
- Telescope fuzzy finder with project management
- Oil.nvim for file management
- Harpoon for quick file navigation
- Flash.nvim for enhanced movement
- Tokyo Night theme
- Conform.nvim for formatting
- Treesitter for syntax highlighting
- Full debugging support with DAP

**Supported Languages:**
- TypeScript/JavaScript (ts_ls, ESLint, Prettier)
- Deno (denols, deno fmt)
- PHP (Intelephense, PHP-CBF, PHPCS)
- Lua (lua_ls, Stylua)
- CSS/SCSS (stylelint_lsp, somesass_ls)
- HTML (emmet_language_server)
- Go (with debugging support)
- Markdown, JSON, Bash

### 🗂️ File Management

#### **Yazi** (`.config/yazi/`)
Terminal file manager with vim-like keybindings.

**Features:**
- Custom theme configuration
- Integrated with Zsh (Ctrl+E hotkey)
- Shell wrapper for directory jumping

### 🎵 Music

#### **MPD** (Music Player Daemon) (`.config/mpd/`)
Flexible music player server architecture.

**Features:**
- Configured for local music playback
- Database and state management
- Sticker support for metadata

#### **RMPC** (Rusty Music Player Client) (`.config/rmpc/`)
Modern MPD client written in Rust.

**Features:**
- RON configuration format
- Terminal-based interface

### 🔧 Version Control

#### **Git** (`.config/git/`)
Version control configuration with SSH signing and multi-identity support.

**Features:**
- GPG signing via SSH (1Password integration)
- Default signing enabled for commits
- Separate configurations for personal and work projects
- Custom URL shortcuts:
  - `jc:` → Personal GitHub repositories
  - `di:` → Work repositories (Digital Impulse)
  - `personal:` → Full personal GitHub access
  - `work:` → Full work GitHub access
- Default branch: main
- Status enhancements: branch info, stash display, untracked files

**Work Context:**
- Automatic config switching for `~/Projects/digitalimpulse/` directory
- Separate identity management for work repositories

#### **SSH** (`.ssh/`)
SSH configuration with 1Password integration.

**Features:**
- 1Password agent for SSH key management
- Separate key pairs for personal and work GitHub access
- Host aliases: `personalgit` and `workgit`
- Identity-only authentication for security

### 🖱️ Desktop Integration

#### **Applications** (`.local/share/applications/`)
Custom desktop entries for application launchers.

**Includes:**
- `local.desktop`: Custom application launcher

## 🎨 Theming

**Consistent theme across all applications: Tokyo Night**

- **Terminal**: Kitty uses Tokyo Night theme
- **Multiplexer**: Zellij uses custom Tokyo Night Night theme
- **Editor**: Neovim uses Tokyo Night theme
- **Color scheme**: Dark background with vibrant, eye-friendly colors

## 🚀 Installation

### Prerequisites

```bash
# Core tools
sudo dnf install git zsh neovim kitty ripgrep fd-find fzf zoxide

# Development tools
sudo dnf install nodejs php lua gcc make

# Optional
sudo dnf install mpd
cargo install yazi-fm zellij rmpc
```

### Setup

1. **Clone this repository:**

```bash
git clone https://github.com/jacocanete/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Backup existing configurations:**

```bash
# Backup existing configs
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.config/kitty ~/.config/kitty.backup
# ... backup other configs as needed
```

3. **Create symbolic links:**

```bash
# Shell configs
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.zshrc ~/.zshrc

# Application configs
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.config/kitty ~/.config/kitty
ln -s ~/dotfiles/.config/zellij ~/.config/zellij
ln -s ~/dotfiles/.config/yazi ~/.config/yazi
ln -s ~/dotfiles/.config/git ~/.config/git
ln -s ~/dotfiles/.config/mpd ~/.config/mpd
ln -s ~/dotfiles/.config/rmpc ~/.config/rmpc

# SSH config
ln -s ~/dotfiles/.ssh/config ~/.ssh/config

# Desktop entries
ln -s ~/dotfiles/.local/share/applications ~/.local/share/applications
```

4. **Install Oh My Zsh:**

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

5. **Install Zsh plugins:**

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

6. **Install FNM (Fast Node Manager):**

```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

7. **Set Zsh as default shell:**

```bash
chsh -s $(which zsh)
```

8. **Install Neovim plugins:**

```bash
nvim
# Lazy.nvim will auto-install on first launch
# Run :Mason to verify LSP installations
```

### SSH & Git Setup

1. **Configure 1Password SSH agent** (if using 1Password):
   - Enable SSH agent in 1Password settings
   - Add SSH keys to 1Password

2. **Add SSH keys** (if not using 1Password):

```bash
# Generate personal key
ssh-keygen -t ed25519 -C "your-personal-email@example.com" -f ~/.ssh/id_rsa_personal

# Generate work key
ssh-keygen -t ed25519 -C "your-work-email@example.com" -f ~/.ssh/id_rsa_work

# Add to GitHub
cat ~/.ssh/id_rsa_personal.pub
cat ~/.ssh/id_rsa_work.pub
```

3. **Update Git config:**

```bash
# Edit .config/git/config with your details
vim ~/.config/git/config
```

## 📝 Customization

### Changing Projects Directory

Edit `.zshrc` to update project paths:

```bash
export LOCALSITES=~/your/local/sites
export PROJECTS=~/your/projects
```

Also update Telescope project search in `.config/nvim/lua/plugins/telescope.lua`.

### Changing Font

Edit `.config/kitty/kitty.conf`:

```conf
font_family Your Preferred Nerd Font
font_size 14.0
```

### Adding New Git Shortcuts

Edit `.config/git/config`:

```gitconfig
[url "git@hostname:org/"]
    insteadOf = "shortcut:"
```

### Customizing Zellij Theme

Edit `.config/zellij/config.kdl` in the `themes` section or change to a different theme:

```kdl
theme "your_theme_name"
```

## 🔑 Key Features

### Multi-Context Git Workflow
- Automatic switching between personal and work Git identities
- SSH key separation for security
- URL shortcuts for faster cloning

### Modern Development Environment
- LSP-powered code intelligence
- AI-assisted completion
- Fast fuzzy finding across projects
- Integrated debugging support

### Terminal Productivity
- GPU-accelerated rendering (Kitty)
- Workspace management (Zellij)
- Smart directory navigation (Zoxide)
- Quick file operations (Yazi)
- Fuzzy everything (FZF)

### Consistent Theming
- Tokyo Night theme across all applications
- JetBrainsMono Nerd Font throughout
- Cohesive visual experience

## 🛠️ Development Tools

### Node.js Management
- **FNM** for fast Node version switching
- Auto-switches on directory change with `.node-version` or `.nvmrc`

### PHP Development
- Laravel Sail integration
- Intelephense LSP
- PHPCS linting
- PHP-CBF formatting

### JavaScript/TypeScript
- Native Node.js support
- Deno runtime with automatic detection
- ESLint + Prettier integration
- TypeScript LSP

### Other Tools
- SDKMAN for JVM languages
- Cargo for Rust development
- Bun runtime support
- Docker integration

## 📚 Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
- [Zellij](https://zellij.dev/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Tokyo Night Theme](https://github.com/folke/tokyonight.nvim)

## 🤝 Contributing

Feel free to fork this repository and customize it to your needs. If you have suggestions or improvements, pull requests are welcome!

## 📄 License

These dotfiles are provided as-is for personal use. Feel free to use, modify, and distribute as needed.

---

**Happy coding! 🚀**
