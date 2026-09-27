# Private network, DNS, and client trust

Read this for ZeroTier, ZTNet, `dev.test` resolution, Fedora clients, or DDEV
certificate trust. Changing these requires explicit approval under the main
skill's safety boundary.

## Topology

The private `homelab-network` has ZeroTier ID `b6ad79b0c8703cd4`.

| Device | ZeroTier address | Role |
| --- | --- | --- |
| Desktop | `10.121.16.18` | Approved development client |
| ProBook | `10.121.16.127` | Approved development client |
| Phone | `10.121.16.132` | OpenCode Web on TCP 4096 only |
| `home-dev` | `10.121.16.20` | Development VM and DNS server |
| `home-server` | `10.121.16.22` | VM control path |

The VM's recovery address is `192.168.122.10` via the libvirt host. Preserve
this path during networking work.

## Private names

`*.dev.test` resolves to `10.121.16.20`. Examples include
`wp-theme-star-engineer.dev.test`, `portfolio.dev.test`, and
`api.portfolio.dev.test`. DNS maps names to the VM, not to a process: direct
services still need a reachable listener and port.

- `dnsmasq` listens on `10.121.16.20:53` and the ZeroTier interface;
  `/etc/dnsmasq.d/ddev-dev-test.conf` defines the wildcard.
- ZTNet distributes the `dev.test` search domain and `10.121.16.20` DNS.
- Clients enable `allowDNS` for `b6ad79b0c8703cd4`.
- Fedora routes only `~dev.test` through `home-dev` with `systemd-resolved`;
  ordinary internet DNS remains unchanged.

Server checks: `systemctl is-active dnsmasq`, `sudo ss -lntup`, and
`sudo dnsmasq --test`. On a configured Linux client, use
`sudo zerotier-cli listnetworks`, `resolvectl dns <zerotier-interface>`,
`resolvectl domain <zerotier-interface>`, and
`resolvectl query <project>.dev.test`.

## Fedora client setup

ZTNet's DNS policy may need explicit application to Fedora's
`systemd-resolved`. Use the tracked, idempotent dotfiles installer:

```bash
stow --dir="$HOME/dotfiles" --target="$HOME" ddev
setup-ddev-client
```

It discovers the authorized ZeroTier interface, enables managed DNS, verifies
the ZTNet policy, installs `zerotier-dev-test-dns.service` for split DNS,
retrieves DDEV's CA over SSH, verifies its pinned SHA-256 fingerprint, adds it
to system trust, and checks DNS/HTTPS against
`wp-theme-star-engineer.dev.test`. If the client has not joined the network,
join and authorize it in ZTNet manually, assign its intended address, confirm
status `OK`, and rerun the installer. Do not silently join or authorize it.

For temporary diagnosis only, without adopting a ZeroTier interface in
NetworkManager:

```bash
sudo resolvectl dns <zerotier-interface> 10.121.16.20
sudo resolvectl domain <zerotier-interface> '~dev.test'
```

Use the installer for persistence. DNS resolution and certificate trust are
separate checks; after installing the DDEV CA, restart browsers and confirm
HTTPS without bypassing verification.
