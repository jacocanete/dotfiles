# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each directory is a stow package that mirrors the home directory structure:

```bash
package-name/
└── .config/
    └── package-name/
        └── config-file
```

## Packages

| Package | Description |
|---------|-------------|
| bash | Bash shell configuration |
| zsh | Zsh shell configuration |
| git | Git configuration and ignore patterns |
| nvim | Neovim configuration |
| kitty | Kitty terminal emulator |
| yazi | Yazi file manager |
| zellij | Zellij terminal multiplexer |
| mpd | Music Player Daemon |
| rmpc | Rust MPD Client |
| ssh | SSH client configuration |
| localwp | Local WP desktop entry |

## Usage

### Install all packages

```bash
cd ~/dotfiles
stow */
```

### Install specific packages

```bash
stow bash zsh nvim git
```

### Uninstall a package

```bash
stow -D nvim
```

### Re-stow (useful after restructuring)

```bash
stow -R nvim
```

## Adding New Configurations

### For ~/.config applications

```bash
# Create package structure
mkdir -p package-name/.config/package-name

# Move existing config
mv ~/.config/package-name/* package-name/.config/package-name/

# Remove original directory
rmdir ~/.config/package-name

# Stow the package
stow package-name
```

### For home directory dotfiles

```bash
# Create package
mkdir package-name

# Move the dotfile
mv ~/.dotfile package-name/

# Stow
stow package-name
```

### For nested paths (e.g., ~/.local/share)

```bash
mkdir -p package-name/.local/share/applications
mv ~/.local/share/applications/app.desktop package-name/.local/share/applications/
stow package-name
```

## Dependencies

- [GNU Stow](https://www.gnu.org/software/stow/)

```bash
# Fedora
sudo dnf install stow

# Ubuntu/Debian
sudo apt install stow

# Arch
sudo pacman -S stow
```
