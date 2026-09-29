# Database and site migrations

## Database operations

Go through DDEV's wrappers, not a direct connection to its database container:

```bash
ddev import-db --file=path/to/database.sql.gz
ddev export-db --file=path/to/database.sql.gz
```

Keep temporary dumps under an ignored path such as `.ddev/.downloads/`, and
confirm the import file exists and is non-empty before importing. If
DDEV rejects an external path, move the file into the project or pipe it on
stdin.

Preview every URL replacement before applying it:

```bash
ddev wp search-replace '<old-url>' 'https://<project-name>.dev.test' --all-tables --precise --dry-run
```

Paste the literal primary URL from `ddev describe`: `$DDEV_PRIMARY_URL`
inside single quotes stays unexpanded. After the preview looks right, run the
real replacement, then flush the cache and rewrite rules.

## WordPress Studio to DDEV

Studio runs on SQLite; the DDEV copy runs on MariaDB.

1. Record the source's disk use, active theme, plugins, uploads, symlinks,
   and URLs.
2. Take Studio's database-only export, which yields MySQL-compatible SQL.
3. Copy the WordPress files into a separate DDEV project, preserving
   permissions and leaving out disposable migration caches.
4. In the copy, remove the Studio SQLite drop-in, database integration,
   loader, and Studio-specific compatibility MU plugins. Read each MU plugin
   before removing it. The usual paths:

   ```text
   wp-content/db.php
   wp-content/database/
   wp-content/mu-plugins/sqlite-database-integration/
   wp-content/mu-plugins/99-studio-loader.php
   ```

5. Configure DDEV and its `wp-config-ddev.php` include as in
   [sites-and-themes.md](sites-and-themes.md).
6. Start DDEV, import the SQL, preview and apply the URL replacement, and
   mount any external theme or plugin repositories.
7. Stop or trash Studio only after the copy passes the skill's Done-when
   checks.

## WP Migrate

WP Migrate runs as a plugin inside the DDEV site:

```bash
ddev wp plugin get wp-migrate-db-pro --fields=name,status,version
```

It needs writable `wp-content/plugins` and `wp-content/uploads` and outbound
connectivity. A pull from a remote site works over private local DNS because
the local site opens the connection; a push into a private local site fails
when the remote server cannot reach it.
