---
name: ddev-wordpress
description: DDEV and WordPress local development, site setup, wp-admin plugins, WP-CLI, WP Migrate, database imports, Studio migrations, snapshots, and dev.test access. Use when creating, migrating, running, debugging, or exposing a WordPress site with DDEV on home-dev.
---

# DDEV WordPress

Use DDEV as the default local WordPress runtime on `home-dev`. Treat each site
as a normal WordPress installation backed by MariaDB, with `wp-admin`, WP-CLI,
Composer, plugin uploads, cron, and filesystem writes available normally.

## Safety

- Inspect the project, worktree, DDEV state, ports, disk usage, database format,
  and linked theme/plugin paths before changing anything.
- Create a named DDEV database snapshot before imports, URL replacements,
  upgrades, or other consequential database changes.
- Never overwrite or remove the source site until the migrated copy passes
  browser, database, plugin, and project checks.
- Never modify or discard unrelated dirty worktree changes. External theme and
  plugin repositories may contain active user work.
- Ask before changing ZeroTier, ZTNet, DNS, UFW, SSH routing, public exposure,
  or standard router ports.
- Do not commit database dumps, uploads, paid plugin archives, license keys,
  credentials, generated certificates, or machine-local paths unless the
  repository explicitly manages them.
- Do not push or pull a production site with WP Migrate without confirming the
  source, destination, included data, and overwrite direction.

## Triage

Run the relevant checks before deciding on setup or migration steps:

```bash
ddev version
ddev list
ddev describe
docker version
ss -lnt
git status --short
```

Within a running site, prefer DDEV's wrappers:

```bash
ddev wp core version
ddev wp option get home
ddev wp option get siteurl
ddev wp theme status
ddev wp plugin status
ddev wp db check
```

Do not use bare `wp`, `php`, `composer`, `mysql`, or Node commands when they need
the project's container runtime. Use `ddev wp`, `ddev exec`, `ddev composer`,
and `ddev mysql` as appropriate.

## New Sites

Use a lowercase project slug and explicitly select the private development TLD:

```bash
mkdir -p /path/to/site
cd /path/to/site
ddev config --project-type=wordpress --docroot=. --project-name=<slug> --project-tld=dev.test
ddev start
ddev wp core download
ddev wp core install --url='$DDEV_PRIMARY_URL' --title='<title>' --admin_user=admin --admin_email='<email>' --prompt=admin_password
```

For a theme development site, use the theme repository slug as the DDEV project
name, for example `wp-theme-star-engineer.dev.test`. This matches the established
LocalWP-style convention while using the shared `dev.test` namespace.

DDEV WordPress runtime sites belong under `~/Sites/<project-name>`. Keep theme
and plugin Git repositories under `~/Projects/jacocanete/` for personal work or
`~/Projects/digitalimpulse/` for work, then mount them into the DDEV site. Do not
place the disposable WordPress runtime inside the theme or plugin repository.

For an existing WordPress site, run `ddev config` in the site root and include
DDEV's generated settings near the end of `wp-config.php`, before loading
`wp-settings.php`:

```php
$ddev_settings = __DIR__ . '/wp-config-ddev.php';
if ( is_readable( $ddev_settings ) && ! defined( 'DB_USER' ) ) {
	require_once $ddev_settings;
}
```

Remove or conditionally bypass conflicting local database constants in the
migrated copy. Do not edit the source configuration destructively.

## Plugins And Themes

WordPress admin plugin management is supported normally. Use whichever method
matches the project:

```bash
ddev wp plugin install <wordpress-org-slug> --activate
ddev wp plugin install /path/to/plugin.zip --activate
ddev wp plugin list
```

Premium plugin ZIPs and licenses remain private. Do not add them to Git.

Host symlinks that point outside the DDEV project root do not resolve inside the
container. Preserve the source repository and mount it explicitly with a DDEV
Docker Compose override. The container destination is normally:

```text
/var/www/html/wp-content/themes/<theme-slug>
```

Ensure the destination in the copied site is a directory rather than an
external symlink, restart DDEV, and verify the mount with `docker inspect` and
`ddev wp theme status`. Keep absolute host paths in a machine-local override
unless the repository intentionally standardizes that path.

## Database Migration

Use DDEV's database operations instead of reaching into the database container:

```bash
ddev snapshot --name=<before-change>
ddev import-db --file=path/to/database.sql.gz
ddev export-db --file=path/to/database.sql.gz
```

Keep temporary dumps under an ignored path such as `.ddev/.downloads/`. If DDEV
rejects an external dump path, move it into the project or use supported stdin
input. Verify the file exists and is non-empty before importing.

Preview URL replacements before applying them:

```bash
ddev wp search-replace '<old-url>' '$DDEV_PRIMARY_URL' --all-tables --precise --dry-run
```

Use the concrete value from `ddev describe` when shell expansion or quoting
would prevent `$DDEV_PRIMARY_URL` from resolving. After approval, run the real
replacement, flush cache and rewrite rules, then run `ddev wp db check`.

## WordPress Studio Migration

Studio uses SQLite. Migrate a copy to DDEV rather than converting the source in
place:

1. Confirm the Studio site, DDEV destination, free disk space, active theme,
   plugins, uploads, symlinks, and current URLs.
2. Export a MySQL-compatible database with Studio's database-only export.
3. Copy WordPress into a separate DDEV project while preserving permissions and
   excluding disposable migration caches.
4. In the copy only, remove Studio's SQLite drop-in, SQLite integration, Studio
   loader, and Studio-specific compatibility MU plugins.
5. Configure DDEV and its `wp-config-ddev.php` include.
6. Start DDEV, import the SQL export, and preview the URL replacement.
7. Mount any theme or plugin repository that was linked from outside the site.
8. Verify the DDEV copy before stopping or trashing Studio.

Common Studio-only paths that must not remain active in the DDEV copy include:

```text
wp-content/db.php
wp-content/database/
wp-content/mu-plugins/sqlite-database-integration/
wp-content/mu-plugins/99-studio-loader.php
```

Do not assume every MU plugin is Studio-specific; inspect each one before
excluding it.

## WP Migrate

WP Migrate should run as a normal WordPress plugin under DDEV and MariaDB:

```bash
ddev wp plugin get wp-migrate-db-pro --fields=name,status,version
```

Check that `wp-content/plugins` and `wp-content/uploads` are writable and that
the local environment has outbound connectivity. Pulling from a remote site is
normally compatible with private local DNS because the local site initiates the
connection. Pushing into a private local site can still fail when the remote
server cannot reach it.

Open and test the WP Migrate admin screen in a browser. Do not claim migration
support based only on plugin activation.

## home-dev Access

Load and follow the `home-dev-networking` skill before configuring or
troubleshooting DNS, TLS, ports, client access, ZeroTier, ZTNet, UFW, or reverse
proxy behavior. That skill is the source of truth for the network architecture;
do not duplicate or independently change those conventions here.

Canonical DDEV URLs use:

```text
https://<project>.dev.test
```

Configure each DDEV project with `project_tld: dev.test`, then use the shared
networking workflow to verify client DNS and HTTPS access.

## Verification

Complete the applicable checks before reporting success:

```bash
ddev describe
ddev wp core is-installed
ddev wp db check
ddev wp theme status
ddev wp plugin status
curl -I https://<project>.dev.test
```

Also verify:

- The front end renders in a real browser.
- `/wp-admin/` reaches login and works after authentication.
- Plugin search, ZIP upload, installation, activation, and deletion are writable
  when relevant to the request.
- WP Migrate's admin screen loads when migration support is required.
- External theme/plugin mounts expose the intended live worktree.
- Existing source sites and unrelated Git changes remain intact.
- The project's own lint, typecheck, tests, and build pass when applicable.

Create a final named database snapshot after a successful migration. Report the
canonical URL, project path, key daily commands, verification performed, and any
remaining client certificate or DNS setup.
