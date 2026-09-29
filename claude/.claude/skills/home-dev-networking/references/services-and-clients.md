# Services and client access

## Direct service access

Bind a browser-facing service to `10.121.16.20` when it supports that,
otherwise to `0.0.0.0` behind the existing firewall; a localhost-only
listener cannot serve remote clients. Backend-only services stay on loopback
behind a frontend proxy. Where the framework supports it, set allowed hosts
to the intended `*.dev.test` name (Astro and Vite both do).

```bash
npm run dev -- --host 0.0.0.0 --port 4321
pocketbase serve --http=0.0.0.0:8090
```

Wildcard DNS resolves the name but keeps the port:

```text
http://portfolio.dev.test:4321
http://api.portfolio.dev.test:8090
```

## Standard ports and HTTPS

DDEV's Traefik router owns ports 80 and 443 on `home-dev`, and it keeps them.
DDEV projects with `project_tld: dev.test` get URLs like
`https://wp-theme-star-engineer.dev.test`; a separate service on 4321 or 8090
still needs its explicit port. When clean HTTPS is required, propose one of:
routing through an appropriate DDEV project, a reviewed route on the existing
Traefik, or a deliberate redesign of shared proxy ownership.

Private HTTPS uses the DDEV local CA; Fedora clients get it from
`setup-ddev-client` (see [private-network-and-dns.md](private-network-and-dns.md)).
`curl --insecure` serves only to separate a trust failure from a reachability
failure.

## Browser and API traffic

Browser-side `localhost` is the client device, not the VM. Prefer relative
requests such as `/api`, with a frontend proxy to the VM-local backend. When
clients must reach the API directly, give it a named `api.<project>.dev.test`
endpoint and configure CORS for the intended origins. Test WebSockets and
server-sent events through every proxy, especially live reload, Metro, and
PocketBase realtime subscriptions.

## Expo on a physical phone

The phone can query private DNS and reach Traefik HTTPS, but Metro (usually
TCP 8081) remains blocked. Test on the device with `npx expo start --tunnel`.
Direct ZeroTier access to Metro needs a separately approved, source-restricted
policy covering the other Expo ports, WebSockets, and Android cleartext HTTP.

## Checks per layer

Pick the smallest set for the failing layer: `ip -brief address`,
`sudo zerotier-cli info`, `sudo zerotier-cli listnetworks`,
`sudo zerotier-cli peers`, `resolvectl status`, `ss -lnt`,
`sudo ss -lntup`, `sudo ufw status verbose`, `docker ps`, and
`curl -I https://<project>.dev.test`.
