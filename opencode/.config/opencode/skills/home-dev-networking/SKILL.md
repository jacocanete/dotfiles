---
name: home-dev-networking
description: home-dev networking and remote development access. Use whenever the user wants a development server, site, app, or API on the VM to be reachable from a phone, laptop, browser, LAN, or remote client, even if networking is not mentioned explicitly. Trigger for inaccessible localhost URLs, bind or listen addresses, port conflicts, service exposure, ZeroTier, ZTNet, dev.test DNS, dnsmasq, systemd-resolved, TLS trust, certificates, UFW, reverse proxies, and connectivity involving Astro, DDEV, PocketBase, Expo, Metro, or other dev servers.
---

# home-dev Networking

Use this skill as the source of truth for reaching development services on the
`home-dev` VM. Other skills should reference this workflow rather than duplicate
addresses, DNS, TLS, firewall, or client configuration.

## Safety Boundary

- Inspect first and explain the intended network change before applying it.
- Ask for explicit approval before changing ZeroTier, ZTNet, DNS, UFW, SSH
  routing, reverse proxies, standard ports, or public exposure.
- Bind only what the task requires. Prefer the ZeroTier address when a service
  supports it; otherwise bind `0.0.0.0` and rely on the existing firewall.
- Never broaden the phone rule for an ordinary development server without a
  separate, explicit decision. Prefer a framework tunnel when practical.
- Do not expose development services publicly or alter the host's recovery path
  as a shortcut.
- Preserve existing listeners. Check ports before starting or reconfiguring a
  service, and identify the owning process before resolving a conflict.
- Do not use `nmcli connection modify` on a ZeroTier interface. ZeroTier creates
  it externally, and NetworkManager may disconnect it when adopting the
  connection.

## Topology

The private `homelab-network` uses ZeroTier network ID
`b6ad79b0c8703cd4`.

| Device | ZeroTier address | Access |
|--------|------------------|--------|
| Desktop | `10.121.16.18` | Approved development client |
| ProBook | `10.121.16.127` | Approved development client |
| Phone | `10.121.16.132` | OpenCode Web on TCP 4096 only |
| `home-dev` | `10.121.16.20` | Development VM and DNS server |
| `home-server` | `10.121.16.22` | VM control path |

The VM also has recovery address `192.168.122.10`, reachable through the
libvirt host. Do not change recovery routing while working on development
access.

## Naming And DNS

All private development hostnames use the reserved testing namespace:

```text
*.dev.test -> 10.121.16.20
```

Examples:

```text
wp-theme-star-engineer.dev.test
portfolio.dev.test
api.portfolio.dev.test
```

The authoritative local path is:

- `dnsmasq` listens on `10.121.16.20:53` and the ZeroTier interface only.
- `/etc/dnsmasq.d/ddev-dev-test.conf` defines the wildcard record.
- ZTNet distributes search domain `dev.test` and DNS server `10.121.16.20`.
- Clients enable `allowDNS` for `b6ad79b0c8703cd4`.
- Fedora clients route only `~dev.test` through `home-dev` using
  `systemd-resolved`; normal internet DNS remains unchanged.

DNS only maps a name to the VM. It does not route a hostname to a process or
remove the need for a service port.

Verify the server side with:

```bash
systemctl is-active dnsmasq
sudo ss -lntup
sudo dnsmasq --test
```

Verify a configured Linux client with:

```bash
sudo zerotier-cli listnetworks
resolvectl dns <zerotier-interface>
resolvectl domain <zerotier-interface>
resolvectl query <project>.dev.test
```

## Fedora Client Setup

ZTNet distributes the DNS policy, but Fedora may not apply that policy to
`systemd-resolved` by itself. Use the tracked, idempotent dotfiles installer:

```bash
stow --dir="$HOME/dotfiles" --target="$HOME" ddev
setup-ddev-client
```

The installer:

- Requires the machine to be authorized and online in `homelab-network`.
- Discovers the network's interface instead of assuming its name.
- Enables ZeroTier managed DNS and validates the ZTNet policy.
- Installs and enables `zerotier-dev-test-dns.service`.
- Routes only `~dev.test` to `10.121.16.20`.
- Retrieves the DDEV CA over SSH, verifies its pinned SHA-256 fingerprint, and
  installs it in Fedora's system trust store.
- Verifies DNS and HTTPS against `wp-theme-star-engineer.dev.test`.

If the machine has not joined the network, join it manually, authorize it in
ZTNet, assign its intended managed address, confirm status `OK`, and rerun the
installer. Do not make the installer silently join or authorize networks.

For temporary diagnosis only, split DNS can be applied without touching
NetworkManager:

```bash
sudo resolvectl dns <zerotier-interface> 10.121.16.20
sudo resolvectl domain <zerotier-interface> '~dev.test'
```

Use the tracked installer for persistence.

## Service Exposure

Before starting a browser-facing service:

1. Determine its required HTTP, WebSocket, API, callback, and live-reload ports.
2. Run `ss -lnt` and confirm each requested port is available.
3. Bind to `10.121.16.20` or `0.0.0.0`, never only `localhost`.
4. Restrict accepted hostnames when the framework supports it.
5. Keep backend-only services on loopback when a frontend proxy is sufficient.
6. Verify from the VM and from the intended client.

For a service listening directly on a development port, the wildcard DNS works
without additional DNS records:

```text
http://portfolio.dev.test:4321
http://api.portfolio.dev.test:8090
```

Always report the actual reachable URL. A DNS name without a reverse-proxy route
still needs the service's port.

Typical bindings include:

```bash
# Astro
npm run dev -- --host 0.0.0.0 --port 4321

# PocketBase
pocketbase serve --http=0.0.0.0:8090
```

For Astro and Vite-based tools, configure the `*.dev.test` hostname in the
framework's allowed-host policy instead of allowing arbitrary hostnames when
possible.

## Ports And HTTPS

DDEV's Traefik router owns standard ports 80 and 443 on `home-dev`. DDEV
projects configured with `project_tld: dev.test` receive clean URLs such as:

```text
https://wp-theme-star-engineer.dev.test
```

An unrelated process on port 4321 or 8090 does not automatically receive a
clean HTTPS URL. The default, low-complexity choice is to retain its explicit
port. If clean HTTPS is required, propose one of these before changing routing:

1. Integrate the service into an appropriate DDEV project and its router.
2. Add a reviewed hostname route to the existing Traefik setup.
3. Redesign the shared reverse-proxy ownership deliberately.

Do not start Caddy, Nginx, or another proxy on ports 80 or 443 alongside DDEV.
Do not move DDEV away from standard ports merely to hide a development port.

Private HTTPS uses DDEV's local certificate authority. DNS and certificate
trust are separate: successful name resolution does not make a certificate
trusted. Use `setup-ddev-client` on Fedora clients and restart browsers after
installing the CA.

## Frontend And API Rules

Browser-side `localhost` refers to the client device, not `home-dev`.

Prefer:

- Relative browser requests such as `/api`.
- A frontend development proxy to a VM-local backend.
- A named `api.<project>.dev.test` endpoint when clients must contact the
  backend directly.
- Explicit CORS configuration when separate origins are intentional.

Verify WebSocket and server-sent event behavior through any proxy, especially
for live reload, Metro, PocketBase realtime subscriptions, and development
tooling.

## Expo And Physical Devices

Metro commonly uses port 8081. The phone currently cannot query the private DNS
server or reach Metro because its UFW allowance is limited to OpenCode Web on
TCP 4096.

Prefer Expo's tunnel when using the physical phone:

```bash
npx expo start --tunnel
```

Direct ZeroTier access would require a separately approved, source-restricted
DNS and Metro firewall policy. Account for additional Expo ports, WebSockets,
Android cleartext HTTP rules, and private CA trust before proposing that change.

## Diagnostics

Use the smallest relevant set:

```bash
ip -brief address
sudo zerotier-cli info
sudo zerotier-cli listnetworks
sudo zerotier-cli peers
resolvectl status
ss -lnt
sudo ss -lntup
sudo ufw status verbose
docker ps
curl -I https://<project>.dev.test
```

Interpret failures by layer:

1. ZeroTier membership and managed address.
2. UFW source policy.
3. DNS policy distributed by ZTNet.
4. Client split-DNS application.
5. TCP listener and bind address.
6. Hostname routing or allowed-host checks.
7. TLS certificate and client trust.
8. Application behavior, proxy headers, WebSockets, or CORS.

Do not bypass TLS verification as the final fix. `curl --insecure` is acceptable
only to isolate whether trust is the failing layer.

## Verification And Rollback

After an approved change, verify both the intended path and preserved paths:

- The target hostname resolves to `10.121.16.20` on the client.
- The required ports listen on the intended VM interface.
- The desktop and/or ProBook can reach the service.
- HTTPS validates without bypass flags when HTTPS is used.
- Existing DDEV sites and OpenCode Web still work.
- The phone remains limited to port 4096 unless explicitly changed.
- Services survive the intended restart or reboot boundary.

Document how to reverse any persistent DNS, firewall, proxy, or systemd change
before considering the work complete.
