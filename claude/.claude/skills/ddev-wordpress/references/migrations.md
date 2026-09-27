# Database and site migrations

Read this for SQL imports, WordPress Studio, WP Migrate, or URL replacement.

## Database operations

Use DDEV's database wrappers rather than connecting directly to its container:

```bash
ddev snapshot --name=<before-change>
ddev import-db --file=path/to/database.sql.gz
ddev export-db --file=path/to/database.sql.gz
```

Keep temporary dumps under an ignored path such as `.ddev/.downloads/`.
Verify the import file exists and is non-empty. If DDEV rejects an external
path, move the file into the project or use supported stdin input.

Preview replacements before applying them:

```bash
ddev wp search-replace '<old-url>' 'https://<project-name>.dev.test' --all-tables --precise --dry-run
```

Use the actual primary URL from `ddev describe` rather than an unexpanded
`$DDEV_PRIMARY_URL` inside single quotes. After confirming the preview, run
the real replacement, flush cache and rewrite rules, then check the database
with `ddev wp db check`.

## WordPress Studio to DDEV

Studio uses SQLite. Migrate a copy to DDEV/MariaDB; leave the source intact
until the copy passes all checks.

1. Confirm source and destination, free disk, active theme, plugins, uploads,
   symlinks, and URLs.
2. Use Studio's database-only export to obtain MySQL-compatible SQL.
3. Copy the WordPress files into a separate DDEV project, preserving permissions
   and excluding disposable migration caches.
4. In the *copy only*, remove the Studio SQLite drop-in, database integration,
   loader, and Studio-specific compatibility MU plugins. Inspect each MU plugin
   before excluding it.
5. Configure DDEV and its `wp-config-ddev.php` include as described in
   [sites-and-themes.md](sites-and-themes.md).
6. Start DDEV, import SQL, preview and apply URL replacement, and mount any
   external theme/plugin repositories.
7. Verify the copy in the browser, database, plugins, and worktree before
   stopping or trashing Studio. Take a final named snapshot.

Common Studio-only paths in the copied site:

```text
wp-content/db.php
wp-content/database/
wp-content/mu-plugins/sqlite-database-integration/
wp-content/mu-plugins/99-studio-loader.php
```

## WP Migrate

WP Migrate runs as a WordPress plugin under DDEV/MariaDB:

```bash
ddev wp plugin get wp-migrate-db-pro --fields=name,status,version
```

Check that `wp-content/plugins` and `wp-content/uploads` are writable and
that the local site has outbound connectivity. A remote-site pull normally
works with private local DNS because the local site initiates the connection;
a push into a private local site may fail if the remote server cannot reach
it. Confirm source, destination, included data, and overwrite direction before
any production push or pull. Test the WP Migrate admin screen in a browser;
activation alone does not establish that migration works.
