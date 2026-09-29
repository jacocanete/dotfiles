# Private network, DNS, and client trust

## Topology

The private `homelab-network` has ZeroTier ID `b6ad79b0c8703cd4`.

| Device | ZeroTier address | Role |
| --- | --- | --- |
| Desktop | `10.121.16.18` | Approved development client |
| ProBook | `10.121.16.127` | Approved development client |
| Phone | `10.121.16.132` | VM DNS 53, Traefik HTTPS 443, OpenCode Web 4096 |
| `home-dev` | `10.121.16.20` | Development VM and DNS server |
| `home-server` | `10.121.16.22` | VM control path |

The VM's recovery address is `192.168.122.10`, reached through the libvirt
host.

## Private names

`*.dev.test` resolves to `10.121.16.20`, for example
`wp-theme-star-engineer.dev.test`, `portfolio.dev.test`, and
`api.portfolio.dev.test`. DNS maps names to the VM, not to a process: a
direct service still needs a reachable listener and port.

- `dnsmasq` listens on `10.121.16.20:53` and the ZeroTier interface;
  `/etc/dnsmasq.d/ddev-dev-test.conf` defines the wildcard.
- ZTNet distributes the `dev.test` search domain and `10.121.16.20` DNS.
- Clients enable `allowDNS` for `b6ad79b0c8703cd4`.
- Fedora routes only `~dev.test` through `home-dev` with `systemd-resolved`;
  ordinary internet DNS is unchanged.

On Android, confirm ZeroTier applies the managed DNS server before testing
`https://opencode.dev.test`. The phone must trust the VM's mkcert root CA for
HTTPS; transfer only `~/.local/share/mkcert/rootCA.pem`, never its private key.
Verify the CA's SHA-256 fingerprint before installing it:
`3A:AA:06:90:55:C7:13:47:31:95:A3:93:21:0C:B8:40:C7:00:8C:14:88:C9:A3:BE:37:ED:8C:1C:5C:DA:47:98`.

Server checks: `systemctl is-active dnsmasq`, `sudo ss -lntup`, and
`sudo dnsmasq --test`. Client checks on configured Linux:
`sudo zerotier-cli listnetworks`, `resolvectl dns <zerotier-interface>`,
`resolvectl domain <zerotier-interface>`, and
`resolvectl query <project>.dev.test`.

## Fedora client setup

Fedora's `systemd-resolved` may ignore ZTNet's DNS policy until it is applied
explicitly. The tracked, idempotent dotfiles installer does that:

```bash
stow --dir="$HOME/dotfiles" --target="$HOME" ddev
setup-ddev-client
```

It discovers the authorized ZeroTier interface, enables managed DNS, verifies
the ZTNet policy, installs `zerotier-dev-test-dns.service` for split DNS,
fetches DDEV's CA over SSH, checks its pinned SHA-256 fingerprint, adds it to
system trust, and tests DNS and HTTPS against
`wp-theme-star-engineer.dev.test`.

A client that has not joined the network needs the user first: they join and
authorize it in ZTNet, assign its intended address, and confirm status `OK`.
Then rerun the installer.

For temporary diagnosis:

```bash
sudo resolvectl dns <zerotier-interface> 10.121.16.20
sudo resolvectl domain <zerotier-interface> '~dev.test'
```

DNS resolution and certificate trust are separate checks. After installing the
DDEV CA, restart browsers before testing HTTPS.
