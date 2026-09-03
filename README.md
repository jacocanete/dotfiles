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
| ssh | SSH client configuration and development VM launcher |
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

### Connect to the development VM

After stowing the `ssh` package, start the VM if needed and connect with:

```bash
home-dev
```

Arguments are passed to SSH as a remote command, for example `home-dev uptime`.
With Zellij 0.45.1 or newer, input automatically routes into the remote session.
Press `Ctrl-g`, `o`, then `]` to return to the local session.

### Development VM network

`home-dev` has its own address on the private `homelab-network`. Use
`10.121.16.20` for SSH and browser access both at home and away. ZeroTier uses
a direct peer path over the physical LAN when possible, so the address does not
need to change on the home network.

| Device | Address | Purpose |
|--------|---------|---------|
| Desktop | `10.121.16.18` | Approved development client |
| ProBook | `10.121.16.127` | Approved future dotfiles client |
| `home-dev` | `10.121.16.20` | Stable SSH and browser endpoint |
| `home-dev` | `192.168.122.10` | Libvirt recovery path through `home-server` |
| `home-server` | `10.121.16.22` | Remote VM control path |
| `home-server` | `192.168.1.5` | Home LAN VM control path |

The guest firewall allows inbound traffic from the desktop and ProBook over
ZTNet. It allows only SSH from the libvirt host and denies other inbound and
routed traffic. The tracked `DOCKER-USER` rules apply the same source policy to
Docker-published ports, which otherwise bypass UFW's normal input rules.

`home-server-dev` connects directly to the VM over ZTNet.
`home-server-dev-recovery` reaches the private libvirt address through the host.
The VM's ED25519 host-key fingerprint is
`SHA256:CkqO/QT55NR8mecAjkSAcOEwJE3qXmWUTqyym7oBda0`.
The guest keeps its own regular `~/.ssh/config` for its dedicated GitHub keys;
do not replace it with the workstation SSH configuration.

#### Rebuild guest network access

Run these commands inside the Ubuntu guest. Each ZeroTier installation must
generate its own identity; never copy `/var/lib/zerotier-one/identity.*` between
machines.

```bash
curl -sSf https://install.zerotier.com | sudo bash
sudo zerotier-cli join b6ad79b0c8703cd4
sudo zerotier-cli info
```

Authorize the new member in ZTNet, assign the guest `10.121.16.20`, and confirm
that `sudo zerotier-cli listnetworks` reports `OK`. The current network interface
is `ztazsqtda4`; substitute the reported interface name if it differs.

After pulling the dotfiles repository in the guest, configure UFW before
running any browser-facing service:

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed
sudo ufw allow in on ztazsqtda4 from 10.121.16.18 comment 'desktop via ZTNet'
sudo ufw allow in on ztazsqtda4 from 10.121.16.127 comment 'ProBook via ZTNet'
sudo ufw allow in on enp1s0 from 192.168.122.1 to any port 22 proto tcp comment 'libvirt host recovery SSH'
sudo ufw route allow in on ztazsqtda4 from 10.121.16.18 comment 'desktop to containers'
sudo ufw route allow in on ztazsqtda4 from 10.121.16.127 comment 'ProBook to containers'
sudo install -o root -g root -m 0640 ~/dotfiles/ssh/.local/share/home-dev/ufw-after.rules /etc/ufw/after.rules
sudo ufw --force enable
```

Verify the resulting policy with:

```bash
sudo zerotier-cli listnetworks
sudo zerotier-cli peers
sudo ufw status verbose
sudo iptables -S DOCKER-USER
```

Use `ssh home-server-dev-recovery` if ZTNet or UFW configuration needs repair.
As an emergency rollback from that recovery session, run `sudo ufw disable`.

The ProBook source address is already allowed in the guest firewall. When its
dotfiles migration begins, join it to `homelab-network`, retain its assigned
`10.121.16.127` address, stow the repository, and verify the VM fingerprint
before using `home-dev`.

#### Browser-facing projects

Bind ordinary development servers to `0.0.0.0` or `10.121.16.20` and open
`http://10.121.16.20:<port>` on an approved client. Browser-side frontend code
must not call a backend at `localhost`, because that resolves on the client.
Prefer relative `/api` requests and a frontend development proxy to a backend
that can remain VM-local.

WordPress Studio sites listen on localhost by default. For direct browser access,
give each site a custom domain through Studio's proxy and map that domain to
`10.121.16.20` on each approved client. Use HTTP initially; HTTPS also requires
trusting Studio's local certificate authority on each client. Studio custom
domains must end in `.local`; for example, map
`10.121.16.20 example.home-dev.local` in the client's `/etc/hosts`. On Linux,
review and run the `setcap` command Studio prints if its proxy needs permission
to bind ports 80 and 443; do not run the entire `studio` command with `sudo`.

### GitHub identities in `home-dev`

The shared Git config rewrites short remote names while the guest's machine-local
SSH config selects a dedicated key for each GitHub account:

| Prefix | GitHub destination | Guest identity |
|--------|--------------------|----------------|
| `jc:` | `jacocanete/<repository>` | Personal VM key |
| `di:` | `digitalimpulse/<repository>` | Work VM key |
| `dd:` | `demanddrive/<repository>` | Work VM key |

For example:

```bash
git clone jc:dotfiles ~/Projects/jacocanete/dotfiles
git clone dd:wp-theme-demanddrive-gtm ~/Projects/digitalimpulse/wp-theme-demanddrive-gtm
```

Authentication follows the remote prefix, but commit identity follows the local
path. Keep work repositories under `~/Projects/digitalimpulse/`; cloning a `dd:`
remote elsewhere does not by itself select the work author or signing key.

The guest uses `~/.ssh/home-dev-github-ed25519` for personal GitHub access and
`~/.ssh/home-dev-work-github-ed25519` for work access. Both are guest-only,
independently revocable keys. Never copy workstation or guest private keys to
another machine. Register only each `.pub` file with its corresponding GitHub
account as an authentication and signing key, including organization SSO when
required.

The machine-local `~/.config/git/local` selects the guest personal signing key.
Its final conditional include loads `~/.config/git/digitalimpulse/local` for work
repositories so that it overrides the shared workstation signing key. These
files and the guest's `~/.ssh/config` intentionally remain outside the tracked
dotfiles.

Verify both identities with:

```bash
ssh -T personalgit
ssh -T workgit
git config user.email
git config user.signingkey
```

### WordPress Studio CLI

The VM uses Node.js 24 through FNM and pins WordPress Studio CLI 1.20.0. The
package includes both site management and the early-access Studio Code agent.

```bash
npm install --global wp-studio@1.20.0
studio --version
studio create --path ~/Projects/example --name example --domain example.home-dev.local --skip-browser
studio start --path ~/Projects/example --skip-browser
studio wp plugin list --path ~/Projects/example
studio code
```

Studio CLI requires Node.js 22 or newer and works best on Node.js 24 or newer.
Use `studio stop --path ~/Projects/example` to stop a site. Do not confuse the
`studio` command with the separate Local WP desktop application or with WP-CLI;
Studio exposes WP-CLI through `studio wp`.

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
