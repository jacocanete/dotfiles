# Services and client access

Read this for exposing a development server, routing HTTPS, browser/API
behavior, Expo, or layered connectivity diagnosis.

## Direct service access

Before starting a browser-facing service, identify its HTTP, WebSocket, API,
callback, and live-reload ports; inspect `ss -lnt` and resolve conflicts by
identifying the owner. Bind to `10.121.16.20` when supported, otherwise
`0.0.0.0` behind the existing firewall. Constrain accepted hostnames when the
framework supports it. Keep backend-only services on loopback behind a
frontend proxy. Verify from both VM and intended client.

Wildcard DNS resolves the hostname but does not remove the port:

```text
http://portfolio.dev.test:4321
http://api.portfolio.dev.test:8090
```

Examples of direct bindings:

```bash
npm run dev -- --host 0.0.0.0 --port 4321
pocketbase serve --http=0.0.0.0:8090
```

Set Astro/Vite allowed hosts to the intended `*.dev.test` hostname rather
than accepting arbitrary hosts. Report the actual reachable URL.

## Standard ports and HTTPS

DDEV's Traefik router owns ports 80 and 443 on `home-dev`. DDEV projects with
`project_tld: dev.test` get URLs like
`https://wp-theme-star-engineer.dev.test`. A separate service on 4321 or 8090
still needs its explicit port. If clean HTTPS is required, propose routing
through an appropriate DDEV project, a reviewed route on existing Traefik,
or a deliberate redesign of shared proxy ownership. Preserve DDEV on 80/443;
do not put another proxy on those ports.

Private HTTPS uses the DDEV local CA. Use `setup-ddev-client` for Fedora trust,
then verify without TLS bypass; `curl --insecure` is only a diagnostic to
separate trust failures from reachability.

## Browser and API traffic

Browser-side `localhost` is the client device, not the VM. Prefer relative
requests such as `/api` and a frontend proxy to a VM-local backend. Use a
named `api.<project>.dev.test` endpoint when clients must reach the API
directly, and configure CORS for intentional cross-origin requests. Check
WebSockets and server-sent events through proxies, especially live reload,
Metro, and PocketBase realtime subscriptions.

## Expo on a physical phone

Metro commonly uses TCP 8081. The phone cannot currently query private DNS or
reach Metro; its UFW access is limited to OpenCode Web on TCP 4096. Prefer
`npx expo start --tunnel` for physical-device testing. Direct ZeroTier access
would need separately approved source-restricted DNS and Metro policy; account
for other Expo ports, WebSockets, Android cleartext HTTP, and private CA trust.

## Diagnose by layer

Choose the smallest relevant checks from `ip -brief address`,
`sudo zerotier-cli info`, `sudo zerotier-cli listnetworks`,
`sudo zerotier-cli peers`, `resolvectl status`, `ss -lnt`,
`sudo ss -lntup`, `sudo ufw status verbose`, `docker ps`, and
`curl -I https://<project>.dev.test`.

Interpret failure in order: ZeroTier membership/address → UFW source policy →
ZTNet DNS policy → client split DNS → listener/bind → hostname routing and
allowed hosts → TLS trust → application, proxy headers, WebSockets, or CORS.
