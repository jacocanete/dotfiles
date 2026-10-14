#!/usr/bin/env bash
# Restore home-dev state from the latest restic snapshots onto a VM that
# bootstrap.sh already built, then start the services. Run as the same user.
set -euo pipefail

DOT=$(cd "$(dirname "$0")" && pwd)
set -a
. "$HOME/.config/restic/env"
set +a
export PATH=$HOME/.local/bin:$PATH

UNITS=(9router headroom-default home-dev-diagnostics opencode-web zellij-web home-dev-backup.timer)

echo "==> stop services so they cannot write over restored state"
systemctl --user stop "${UNITS[@]}" opendesign 2>/dev/null || true
docker compose -f "$HOME/.config/hindsight/compose.yaml" down 2>/dev/null || true

echo "==> files"
# Snapshots hold absolute paths, so restoring at / puts everything back in place.
restic restore latest --tag files --host home-dev --target /

echo "==> trust the restored DDEV CA locally"
# Clients already trust this CA; a regenerated one would break every dev.test certificate.
mkcert -install

echo "==> docker volumes"
restic snapshots --tag volume --host home-dev --latest 1 --json |
  jq -r '.[].paths[0]' | sort -u |
  while read -r path; do
    vol=$(basename "$path" .tar)
    # Never extract over live data: an existing volume means it was restored or recreated already.
    if docker volume inspect "$vol" >/dev/null 2>&1; then
      echo "skip $vol: volume exists (docker volume rm it to restore again)"
      continue
    fi
    docker volume create "$vol" >/dev/null
    restic dump --tag volume --host home-dev --path "$path" latest "$path" |
      docker run --rm -i -v "$vol:/v" alpine:3.20 tar -C /v -xf -
    echo "restored $vol"
  done

echo "==> re-link dotfiles over restored files"
stow --no-folding --restow --ignore='^/\.ssh' -d "$DOT" -t "$HOME" \
  agents backup claude ddev git hindsight lazygit nvim opencode services ssh yazi zellij zsh

echo "==> services"
# The compose stacks join DDEV's router network, which only exists once a DDEV project has started.
docker network inspect ddev_default >/dev/null 2>&1 || docker network create ddev_default >/dev/null
docker compose -f "$HOME/.config/hindsight/compose.yaml" up -d
docker compose -f "$HOME/.config/filebrowser/docker-compose.yaml" up -d
systemctl --user daemon-reload
systemctl --user enable "${UNITS[@]}"
# restart, not start: picks up EnvironmentFiles and state restored above.
systemctl --user restart "${UNITS[@]}"
if [[ -e $HOME/.config/systemd/user/opendesign.service ]]; then
  systemctl --user enable opendesign && systemctl --user restart opendesign
fi

echo "Restore complete. Re-clone projects and re-pull DDEV sites as needed."
