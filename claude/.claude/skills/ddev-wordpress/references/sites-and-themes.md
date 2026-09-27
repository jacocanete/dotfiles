# Sites, plugins, and theme development

Read this for new or existing sites, plugin management, and live theme development.

## Site setup

Keep disposable WordPress runtimes under `~/Sites/<project-name>`; keep personal
theme/plugin Git repositories under `~/Projects/jacocanete/` and work repositories
under `~/Projects/digitalimpulse/`. Use a lowercase project slug and the private
`dev.test` TLD. A theme development site's DDEV name should match its theme repo
slug (for example, `wp-theme-star-engineer.dev.test`).

```bash
mkdir -p ~/Sites/<project-name>
cd ~/Sites/<project-name>
ddev config --project-type=wordpress --docroot=. --project-name=<project-name> --project-tld=dev.test
ddev start
ddev wp core download
ddev wp core install --url='https://<project-name>.dev.test' --title='<title>' --admin_user=admin --admin_email='<email>' --prompt=admin_password
```

For an existing WordPress copy, run `ddev config` in its site root. Include
DDEV's generated settings near the end of `wp-config.php`, before loading
`wp-settings.php`:

```php
$ddev_settings = __DIR__ . '/wp-config-ddev.php';
if ( is_readable( $ddev_settings ) && ! defined( 'DB_USER' ) ) {
	require_once $ddev_settings;
}
```

Conditionally bypass conflicting database constants in the *copy*, preserving
the source configuration.

## Plugins and mounts

WordPress admin plugin management works normally; choose the method that fits
the site:

```bash
ddev wp plugin install <wordpress-org-slug> --activate
ddev wp plugin install /path/to/plugin.zip --activate
ddev wp plugin list
```

Premium ZIPs and license keys stay private. Host symlinks that point outside
the DDEV project do not resolve inside the container. Mount the Git repository
with a machine-local `.ddev/docker-compose.theme.yaml` override instead:

```yaml
services:
  web:
    volumes:
      - /absolute/host/path/to/theme:/var/www/html/wp-content/themes/<theme-slug>
```

Confirm the destination has no unrelated files and is a directory rather than
an external symlink. Restart DDEV; inspect the mount with `docker inspect` and
verify WordPress sees the intended slug with `ddev wp theme status`. Keep
absolute host paths out of tracked configuration unless the project explicitly
standardizes them.

## Live theme workflow

Run theme asset tooling on the host from its Git repository, not through
`ddev exec`. For BrowserSync, create an ignored `.env` from the sample with
`APP_URL=https://<project-name>.dev.test` and `NODE_ENV=development`. It proxies
the DDEV site while the host runs `npm run dev`; check that its usual ports
3000 and 3001 are free first. Load `home-dev-networking` for bind, firewall,
DNS, TLS, or remote access changes.

Before installing dependencies, check the repository's Node engine and npm
major. Prefer `npm ci`; if the lockfile is out of sync, ask before rewriting
it. Run Composer through `ddev composer` when it needs the container PHP
runtime. Inspect required plugins before activation: ACF themes can fatal if
`get_field()` or block registration APIs are missing.

Snapshot the database before changing theme state. On multisite, network
enable the theme before activating it on the intended site:

```bash
ddev wp theme enable <theme-slug> --network
ddev wp theme activate <theme-slug> --url='https://<project-name>.dev.test'
```

Finish with the theme's build, lint, typecheck, and tests; inspect its Git
worktree; verify the front end and authenticated admin in a real browser.
