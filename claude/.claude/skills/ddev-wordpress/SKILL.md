---
name: ddev-wordpress
description: Local WordPress work on home-dev. Use for creating, running, repairing, testing, or migrating a WP site (including Studio and WP Migrate), even when DDEV is not named; also for wp-admin, WP-CLI, plugin/theme development, Composer, SQL imports, snapshots, and dev.test site access.
---

# DDEV WordPress

Use DDEV as the default local WordPress runtime on `home-dev`. Treat it as a
normal WordPress installation with MariaDB, admin access, WP-CLI, Composer,
uploads, cron, and filesystem writes. Keep the site runtime separate from
theme and plugin Git repositories.

## Work from evidence

1. Inspect the site and worktree, DDEV/Docker state, ports, disk, database
   format, and linked theme/plugin paths before choosing a workflow. Use the
   checks relevant to the task: `ddev version`, `ddev list`, `ddev describe`,
   `docker version`, `ss -lnt`, and `git status --short`. For a running site,
   check WordPress version, `home` and `siteurl`, theme/plugin status, and
   database health with `ddev wp`.
2. Protect the source: preserve unrelated worktree changes and external
   theme/plugin repositories. Take a named DDEV snapshot before an import,
   URL replacement, upgrade, or other consequential database change. Migrate
   a copy; retain the source until the copy passes the checks below.
3. Follow the branch that matches the task:
   - New/existing site, plugin install, external mount, or live theme workflow:
     [sites-and-themes.md](references/sites-and-themes.md).
   - SQL import/export, Studio migration, URL replacement, or WP Migrate:
     [migrations.md](references/migrations.md).
   - DNS, TLS, ports, remote browser/client access, ZeroTier, ZTNet, UFW, or
     proxy behavior: load the `home-dev-networking` skill before changing it.
4. Verify the site and affected workflow, then report the URL, site path,
   daily commands, checks performed, and any client DNS/certificate setup
   still required.

Use `ddev wp`, `ddev exec`, `ddev composer`, and `ddev mysql` for commands that
need the container's runtime; host `wp`, `php`, `composer`, `mysql`, or Node
may operate on a different environment. Theme asset tooling is the exception:
run it from the host theme repository as described in the theme reference.

## Approval and data boundaries

- Confirm production source, destination, included data, and overwrite
  direction before any WP Migrate push or pull.
- Ask before changing ZeroTier, ZTNet, DNS, UFW, SSH routing, public exposure,
  or standard router ports; `home-dev-networking` owns that workflow.
- Keep database dumps, uploads, paid plugin ZIPs, license keys, credentials,
  generated certificates, and machine-local paths out of Git unless the repo
  intentionally manages them.

## Done when

For the affected site, check `ddev describe`, `ddev wp core is-installed`,
`ddev wp db check`, theme/plugin status, and the canonical
`https://<project>.dev.test` URL as applicable. Verify the front end in a
real browser and `/wp-admin/` after authentication. Test plugin search,
upload, activation, and deletion when relevant; check WP Migrate's admin
screen, live mounts, and the project's own build/lint/typecheck/tests when
those workflows are involved. Confirm source
sites and unrelated Git changes are intact. After a successful migration,
take a final named database snapshot.
