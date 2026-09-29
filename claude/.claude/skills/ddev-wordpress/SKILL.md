---
name: ddev-wordpress
description: Local WordPress sites on home-dev, run under DDEV even when DDEV is not named. Use for creating, repairing, or testing a WP site; plugin or theme development; WP-CLI or wp-admin work; SQL imports and snapshots; Studio or WP Migrate migrations; and `*.dev.test` URLs.
---

# DDEV WordPress

DDEV is the local WordPress runtime on `home-dev`: a full install with
MariaDB, WP-CLI, and writable uploads. The site runtime lives apart from the
theme and plugin Git repositories it mounts.

## Steps

1. **Inspect.** Use `ddev list`, `ddev describe`, `docker version`,
   `ss -lnt`, `git status --short`, and `ddev wp` as the task needs. Done
   when you know the site path, whether DDEV runs it, its primary URL, its
   `home` and `siteurl`, and which external repositories it mounts.
2. **Snapshot.** Before an import, URL replacement, upgrade, theme switch, or
   other consequential database change, run `ddev snapshot --name=<label>`.
   Migrate a *copy*; the source stays untouched until the copy passes the
   checks in [Done when](#done-when).
3. **Branch.**
   - New or existing site, plugins, external mounts, or live theme work:
     [sites-and-themes.md](references/sites-and-themes.md).
   - SQL import or export, URL replacement, Studio, or WP Migrate:
     [migrations.md](references/migrations.md).
   - DNS, TLS, ports, remote access, ZeroTier, UFW, or proxy behavior: load
     the `home-dev-networking` skill, which owns those changes and their
     approvals.
4. **Verify and report.** Pass every applicable check in
   [Done when](#done-when), then report the URL, site path, daily commands,
   checks run, and any client DNS or certificate setup still required.

Run PHP-side commands through `ddev wp`, `ddev exec`, `ddev composer`, and
`ddev mysql`: host `wp`, `php`, `composer`, and `mysql` hit a different
runtime. Theme asset tooling is the exception and runs on the host (see the
theme reference).

## Boundaries

- Before any WP Migrate push or pull, confirm source, destination, included
  data, and overwrite direction with the user.
- Database dumps, uploads, premium plugin ZIPs, license keys, credentials,
  certificates, and machine-local paths stay out of Git unless the repository
  deliberately manages them.

## Done when

Every check that applies to the affected site passes:

- `ddev describe`, `ddev wp core is-installed`, and `ddev wp db check`.
- Theme and plugin status match the intent.
- `https://<project>.dev.test` renders in a real browser, and `/wp-admin/`
  loads after login.
- Plugin search, upload, activation, and deletion work, when plugins were
  touched.
- The WP Migrate admin screen works in a browser; activation alone proves
  nothing.
- Mounted repositories pass their own build, lint, typecheck, and tests.
- Source sites and unrelated Git changes are intact.
- After a migration, a final named snapshot exists.
