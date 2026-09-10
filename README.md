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
| ddev | Private DNS and HTTPS trust setup for DDEV sites on `home-dev` |
| localwp | Local WP desktop entry |
| opencode | OpenCode configuration, skills, and `home-dev` Web service |

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

Upload a local screenshot or other file to the guest with:

```bash
home-dev send /path/to/screenshot.png
```

The file is placed in `~/Uploads` on `home-dev`. The command prints its exact
remote path and copies that path to the local clipboard when `wl-copy` is
available. In the remote OpenCode TUI, paste the path with the terminal's
`Ctrl+Shift+V` shortcut. OpenCode recognizes the pasted image path and adds it
to the prompt as an attachment.

### Development VM network

`home-dev` has its own address on the private `homelab-network`. Use
`10.121.16.20` for SSH and browser access both at home and away. ZeroTier uses
a direct peer path over the physical LAN when possible, so the address does not
need to change on the home network.

| Device | Address | Purpose |
|--------|---------|---------|
| Desktop | `10.121.16.18` | Approved development client |
| ProBook | `10.121.16.127` | Approved future dotfiles client |
| Phone | `10.121.16.132` | OpenCode Web client only |
| `home-dev` | `10.121.16.20` | Stable SSH and browser endpoint |
| `home-dev` | `192.168.122.10` | Libvirt recovery path through `home-server` |
| `home-server` | `10.121.16.22` | Remote VM control path |
| `home-server` | `192.168.1.5` | Home LAN VM control path |

The guest firewall allows inbound traffic from the desktop and ProBook over
ZTNet. The phone can reach only OpenCode Web on TCP port 4096. It allows only
SSH from the libvirt host and denies other inbound and routed traffic. The
tracked `DOCKER-USER` rules apply the desktop and ProBook source policy to
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
sudo ufw allow in on ztazsqtda4 from 10.121.16.132 to 10.121.16.20 port 4096 proto tcp comment 'phone to OpenCode web'
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

DDEV sites use private wildcard DNS through `home-dev` and names under
`dev.test`, such as `https://wp-theme-star-engineer.dev.test`. ZTNet distributes
the `dev.test` search domain and `10.121.16.20` DNS server. Approved Fedora
clients can install persistent split DNS and trust the DDEV certificate
authority with:

```bash
stow --dir="$HOME/dotfiles" --target="$HOME" ddev
setup-ddev-client
```

The machine must already be authorized and online in `homelab-network`. The
script exits with join instructions otherwise; it does not join or modify
NetworkManager. It discovers the ZeroTier interface, enables managed DNS,
installs a `systemd-resolved` split-DNS service, verifies the pinned DDEV CA
fingerprint, updates Fedora's trust store, and tests the site. Normal internet
DNS remains unchanged because only `~dev.test` is routed through `home-dev`.

### OpenCode Web on `home-dev`

Open `http://10.121.16.20:4096` from the desktop, ProBook, or phone while the
client is connected to `homelab-network`. The systemd user service starts with
the VM and retries until the guest's ZeroTier address is ready. It binds only to
`10.121.16.20`; do not change it to `0.0.0.0`, enable mDNS, or expose the port
through a public proxy.

This endpoint intentionally uses ZTNet and UFW instead of HTTP Basic Auth. An
approved client can use OpenCode to read files and run commands as the guest
user. The phone firewall rule is limited to TCP port 4096, while the desktop and
ProBook retain broader development access.

Deploy and enable the tracked service inside the guest:

```bash
stow --no-folding --restow --dir="$HOME/dotfiles" --target="$HOME" opencode
sudo loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now opencode-web.service
```

`--no-folding` keeps systemd's machine-local enablement link outside the
dotfiles repository. The service adds the OpenCode and FNM paths, optionally
loads the guest-only `~/.secrets` file for MCP credentials, and explicitly
leaves OpenCode server authentication disabled.

Inspect or restart it with:

```bash
systemctl --user status opencode-web.service
journalctl --user-unit opencode-web.service
systemctl --user restart opencode-web.service
```

Disable remote OpenCode access without changing the firewall rule with:

```bash
systemctl --user disable --now opencode-web.service
```

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

### DDEV WordPress

WordPress development runs in DDEV on `home-dev`. The DDEV router binds to the
VM's private interfaces on ports 80 and 443, while UFW restricts access to
approved ZTNet clients. Project names automatically become `dev.test` domains;
WordPress theme sites use the theme repository slug as the project name.

```bash
cd ~/Sites/wp-theme-star-engineer
ddev start
ddev describe
ddev wp plugin list
ddev snapshot
```

The Star Engineering site is available at:

```text
https://wp-theme-star-engineer.dev.test
```

Keep browser-side requests relative and run WordPress commands through
`ddev wp`. DDEV stores project configuration in `.ddev/` and database state in
Docker volumes; use `ddev export-db` for portable database backups.

### Yazi on Ubuntu

Ubuntu 24.04 does not provide Yazi in its default repositories. Install the
official stable repository after verifying its downloaded keyring is not empty:

```bash
curl -fL --retry 5 --retry-all-errors \
  -o /tmp/yazi-keyring.gpg \
  https://yazi-rs.github.io/builds/yazi-keyring.gpg
test -s /tmp/yazi-keyring.gpg
gpg --batch --show-keys --with-subkey-fingerprint /tmp/yazi-keyring.gpg
sudo install -o root -g root -m 0644 /tmp/yazi-keyring.gpg /usr/share/keyrings/yazi-keyring.gpg
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' \
  | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null
rm /tmp/yazi-keyring.gpg
sudo apt update
sudo apt install yazi
stow --dir=~/dotfiles --target=~ --restow yazi
```

The expected primary key fingerprint is
`B77B 412E 5B65 3539 B786 95DC 9243 8579 6056 0E6C`; its signing subkey ends
in `3C761BB7F5D34304`. The stable package includes Yazi's media and document
preview dependencies. Verify the binary and shared theme with `yazi --version`.

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
