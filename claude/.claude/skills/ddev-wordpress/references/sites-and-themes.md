# Sites, plugins, and theme development

## Site setup

Disposable WordPress runtimes live under `~/Sites/<project-name>`. Theme and
plugin Git repositories live under `~/Projects/jacocanete/` (personal) or
`~/Projects/digitalimpulse/` (work). Use a lowercase project slug and the
private `dev.test` TLD. A theme development site takes its theme repository's
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
DDEV's generated settings near the end of `wp-config.php`, before
`wp-settings.php` loads:

```php
$ddev_settings = __DIR__ . '/wp-config-ddev.php';
if ( is_readable( $ddev_settings ) && ! defined( 'DB_USER' ) ) {
	require_once $ddev_settings;
}
```

Where the copy's own database constants conflict, bypass them conditionally
in the copy and leave the source configuration as it is.

## External mounts

Host symlinks that point outside the DDEV project do not resolve inside the
container. Mount the Git repository with a machine-local
`.ddev/docker-compose.theme.yaml` override instead:

```yaml
services:
  web:
    volumes:
      - /absolute/host/path/to/theme:/var/www/html/wp-content/themes/<theme-slug>
```

The mount target must be an empty directory, not an external symlink. Restart
DDEV, confirm the mount with `docker inspect`, and confirm WordPress sees the
intended slug with `ddev wp theme status`. Absolute host paths stay out of
tracked configuration unless the project standardizes them.

## Live theme workflow

Theme asset tooling runs on the host from the theme's Git repository. For
BrowserSync, create an ignored `.env` from the sample with
`APP_URL=https://<project-name>.dev.test` and `NODE_ENV=development`; it
proxies the DDEV site while the host runs `npm run dev`. Check that its usual
ports, 3000 and 3001, are free first.

Before installing dependencies, match the repository's Node engine and npm
major. Use `npm ci`; if the lockfile is out of sync, ask before rewriting it.
Read the theme's required plugins before activating it: ACF themes fatal when
`get_field()` or the block registration APIs are missing.

On multisite, network-enable the theme before activating it on the intended
site:

```bash
ddev wp theme enable <theme-slug> --network
ddev wp theme activate <theme-slug> --url='https://<project-name>.dev.test'
```
