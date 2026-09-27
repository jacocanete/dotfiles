---
name: home-dev-networking
description: Remote access to development services on home-dev. Use when a site, app, or API must work from a phone, laptop, browser, LAN, or remote client; also for unreachable localhost URLs, bind addresses, port conflicts, ZeroTier, ZTNet, dev.test DNS, TLS trust, UFW, reverse proxies, and Astro, DDEV, PocketBase, Expo, or Metro connectivity.
---

# home-dev networking

This is the network source of truth for development services on `home-dev`.
Its stable private address is `10.121.16.20`; approved clients use ZeroTier.
Start with the client's route to the service, not just whether the VM can
reach itself.

## Reachability workflow

1. Identify the intended client, URL, service process, HTTP/WebSocket/API
   ports, and whether DNS and HTTPS are needed. Check current listeners with
   `ss -lnt` and identify their owners before resolving a port conflict.
2. Separate the failure by layer: network membership, UFW source policy,
   DNS, listener/bind, hostname routing, TLS trust, then application/proxy
   behavior. Run only the checks relevant to the failing layer.
3. Read the branch that applies before changing configuration:
   - ZeroTier, ZTNet, `dev.test`, Fedora split DNS, client certificates:
     [private-network-and-dns.md](references/private-network-and-dns.md).
   - Service bindings, ports, DDEV Traefik, frontend/API access, Expo, or
     layered diagnostics: [services-and-clients.md](references/services-and-clients.md).
4. Verify the target path from the intended client and the preserved paths
   below. Report the actual reachable URL (including port when required) and
   how to reverse any persistent networking change.

## Change boundary

- Inspect and explain a network change before applying it. Ask for explicit
  approval before changing ZeroTier, ZTNet, DNS, UFW, SSH routing, reverse
  proxies, standard ports, or public exposure.
- Prefer a service bound to `10.121.16.20` if supported; otherwise use
  `0.0.0.0` behind the existing firewall. A listener bound only to localhost
  cannot serve remote browser clients. Keep backend-only services on VM
  loopback behind a frontend proxy.
- The phone at `10.121.16.132` may reach only OpenCode Web on TCP 4096. Use a
  framework tunnel for ordinary phone development unless a separate policy
  change is approved.
- Preserve the libvirt recovery path and existing listeners. Never adopt a
  ZeroTier interface with `nmcli connection modify`: NetworkManager may
  disconnect an externally created interface.

## Done when

From the intended client, confirm DNS resolves to `10.121.16.20` when used,
the requested port is reachable, and HTTPS validates without bypass flags
when applicable. Check WebSockets/API calls where used, verify DDEV sites and
OpenCode Web still work, and confirm the phone remains limited to TCP 4096.
For persistent changes, check behavior across the intended restart/reboot
boundary and record the rollback path.
