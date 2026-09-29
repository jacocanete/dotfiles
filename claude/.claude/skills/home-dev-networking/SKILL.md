---
name: home-dev-networking
description: Reaching development services on home-dev from another device (phone, laptop, remote browser). Use for unreachable or localhost-only URLs, bind addresses, port conflicts, ZeroTier or ZTNet, `dev.test` DNS, TLS certificate trust, UFW, reverse proxies, and Expo or Metro on a phone.
---

# home-dev networking

`home-dev` sits at `10.121.16.20`; approved clients reach it over ZeroTier.
Judge every result from the intended client: the VM reaching itself proves
nothing about the client's route.

## Steps

1. **Scope.** Done when you know the intended client, the URL, the service
   process, every port it uses (HTTP, WebSocket, API, callback, live
   reload), the current owner of each port from `ss -lnt`, and whether DNS
   and HTTPS are needed.
2. **Find the failing layer.** Walk the layers in order and stop at the
   first that fails: ZeroTier membership and address → UFW source policy →
   ZTNet DNS policy → client split DNS → listener and bind → hostname routing
   and allowed hosts → TLS trust → application, proxy headers, WebSockets, or
   CORS. Run only that layer's checks.
3. **Branch** before changing configuration:
   - ZeroTier, ZTNet, `dev.test` DNS, Fedora split DNS, or client
     certificates: [private-network-and-dns.md](references/private-network-and-dns.md).
   - Binds, ports, DDEV Traefik, frontend and API access, Expo, or per-layer
     check commands: [services-and-clients.md](references/services-and-clients.md).
4. **Verify and report.** Pass every applicable check in
   [Done when](#done-when), then report the reachable URL (with its port when
   one is required) and how to reverse any persistent change.

## Boundaries

- Explain a network change before applying it, and get explicit approval
  before changing ZeroTier, ZTNet, DNS, UFW, SSH routing, reverse proxies,
  standard ports, or public exposure.
- The phone at `10.121.16.132` reaches the VM's SSH on TCP 22, mosh on
  UDP 60000-61000, DNS on TCP/UDP 53, Traefik HTTPS on TCP 443, and
  OpenCode Web directly on TCP 4096.
  Other development ports still require a separate policy change.
- Keep the libvirt recovery path and existing listeners working.
- ZeroTier interfaces stay outside NetworkManager: `nmcli connection modify`
  on one can disconnect it. Use `resolvectl` for temporary DNS and
  `setup-ddev-client` for persistent DNS.

## Done when

From the intended client, every check that applies passes:

- DNS resolves the name to `10.121.16.20`.
- The requested port is reachable.
- HTTPS validates with no bypass flag.
- WebSockets and API calls work.
- DDEV sites and OpenCode Web still work, and the phone reaches only
  the approved SSH, mosh, DNS, HTTPS, and direct OpenCode ports.
- Persistent changes survive the intended restart or reboot, and the
  rollback path is recorded.
