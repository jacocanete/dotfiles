#!/usr/bin/env bash
# Rebuild the home-dev toolchain on a fresh Ubuntu 24.04 VM, then stow the
# dotfiles. Safe to re-run. State and secrets come back later via restore.sh.
set -euo pipefail

DOT=$(cd "$(dirname "$0")" && pwd)
APT_SRC=$DOT/ssh/.local/share/home-dev/apt
BIN=$HOME/.local/bin
OPT=$HOME/.local/opt
FNM_DIR=$HOME/.local/share/fnm
mkdir -p "$BIN" "$OPT" "$FNM_DIR"

# Versions home-dev ran on 2026-10-14. Bump deliberately, not by accident.
NODE=24.0.1
FNM=1.38.1
NVIM=0.11.5
ZELLIJ=0.45.1
LAZYGIT=0.62.2
GH=2.100.0
UV=0.12.19
CLOUDFLARED=2026.9.3
RESTIC=0.18.1
CLAUDE=2.1.300
HEADROOM=0.39.1
NPM_GLOBALS=(
  9router@0.5.95
  @alibaba-group/open-code-review@1.13.0
  @hubspot/cli@8.15.0
  @openai/codex@0.154.0
  @opencode/cli@2.0.22
  @bitwarden/cli@2026.9.1
  agent-browser@0.36.0
  firecrawl-cli@1.24.6
  tree-sitter-cli@0.27.0
  vscode-langservers-extracted@4.10.0
  wp-studio@1.20.0
)
# Desktop-only packages (kitty, localwp, mpd, rmpc) and bash stay off the VM.
STOW_PACKAGES=(agents backup claude ddev git hindsight lazygit nvim opencode services ssh yazi zellij zsh)

log() { printf '\n==> %s\n' "$*"; }

# gh_asset REPO TAG REGEX prints the download URL of the matching release asset.
# Asset names drift between releases, so match by pattern, not a fixed name.
gh_asset() {
  curl -fsSL "https://api.github.com/repos/$1/releases/tags/$2" |
    jq -r --arg re "$3" '.assets[].browser_download_url | select(test($re))' | head -n1 |
    grep . || { echo "no asset matching $3 in $1@$2" >&2; return 1; }
}

fetch() { curl -fL --retry 3 -o "$2" "$1"; }

log "apt repositories and packages"
sudo install -d -m 0755 /etc/apt/keyrings
sudo install -m 0644 "$APT_SRC"/ddev.asc "$APT_SRC"/docker.asc /etc/apt/keyrings/
sudo install -m 0644 "$APT_SRC"/yazi-keyring.gpg "$APT_SRC"/zerotier-debian-package-key.gpg /usr/share/keyrings/
sudo install -m 0644 "$APT_SRC"/*.sources "$APT_SRC"/*.list /etc/apt/sources.list.d/
sudo apt-get update
# The bootloader and kernel belong to the VM image, so the package list leaves them out.
xargs -a "$DOT/packages-home-dev.txt" sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y yazi
sudo usermod -aG docker "$USER"
sudo loginctl enable-linger "$USER"
[[ $(getent passwd "$USER" | cut -d: -f7) == */zsh ]] || sudo chsh -s "$(command -v zsh)" "$USER"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

log "release binaries"
if [[ ! -x $OPT/nvim/bin/nvim ]] || ! "$OPT/nvim/bin/nvim" --version | grep -q "v$NVIM"; then
  fetch "$(gh_asset neovim/neovim "v$NVIM" 'nvim-linux-x86_64\.tar\.gz$')" "$tmp/nvim.tgz"
  rm -rf "$OPT/nvim" && mkdir -p "$OPT/nvim"
  tar -xzf "$tmp/nvim.tgz" -C "$OPT/nvim" --strip-components=1
fi
ln -sfn "$OPT/nvim/bin/nvim" "$BIN/nvim"
ln -sfn /usr/bin/fdfind "$BIN/fd"

fetch "$(gh_asset zellij-org/zellij "v$ZELLIJ" 'x86_64-unknown-linux-musl\.tar\.gz$')" "$tmp/zellij.tgz"
tar -xzf "$tmp/zellij.tgz" -C "$BIN" zellij
fetch "$(gh_asset jesseduffield/lazygit "v$LAZYGIT" '[Ll]inux_x86_64\.tar\.gz$')" "$tmp/lazygit.tgz"
tar -xzf "$tmp/lazygit.tgz" -C "$BIN" lazygit
fetch "$(gh_asset cli/cli "v$GH" 'linux_amd64\.tar\.gz$')" "$tmp/gh.tgz"
tar -xzf "$tmp/gh.tgz" -C "$tmp" && install -m 0755 "$tmp"/gh_*/bin/gh "$BIN/gh"
fetch "$(gh_asset cloudflare/cloudflared "$CLOUDFLARED" 'cloudflared-linux-amd64$')" "$tmp/cloudflared"
install -m 0755 "$tmp/cloudflared" "$BIN/cloudflared"
fetch "$(gh_asset restic/restic "v$RESTIC" 'linux_amd64\.bz2$')" "$tmp/restic.bz2"
bunzip2 -c "$tmp/restic.bz2" > "$tmp/restic" && install -m 0755 "$tmp/restic" "$BIN/restic"

log "installer-managed tools"
command -v uv >/dev/null && uv --version | grep -q "$UV" ||
  curl -LsSf "https://astral.sh/uv/$UV/install.sh" | env UV_NO_MODIFY_PATH=1 sh
"$BIN/uv" tool install --force "headroom-ai==$HEADROOM"
# ponytail: GitButler's installer has no version pin; it installs the current release.
command -v but >/dev/null || curl -fsSL https://gitbutler.com/install.sh | sh
[[ -x $BIN/claude ]] && "$BIN/claude" --version | grep -q "$CLAUDE" ||
  curl -fsSL https://claude.ai/install.sh | bash -s "$CLAUDE"

log "node $NODE and global npm packages"
if [[ ! -x $FNM_DIR/fnm ]]; then
  fetch "$(gh_asset Schniz/fnm "v$FNM" 'fnm-linux\.zip$')" "$tmp/fnm.zip"
  unzip -o -q "$tmp/fnm.zip" -d "$FNM_DIR" && chmod +x "$FNM_DIR/fnm"
fi
export FNM_DIR
"$FNM_DIR/fnm" install "$NODE"
"$FNM_DIR/fnm" default "$NODE"
NODE_BIN=$FNM_DIR/node-versions/v$NODE/installation/bin
PATH=$NODE_BIN:$PATH "$NODE_BIN/npm" install -g "${NPM_GLOBALS[@]}"
ln -sfn "$HOME/.config/opencode/skills/9router-web-search/scripts/9r" "$BIN/9r"

log "stow dotfiles"
# Before oh-my-zsh: its installer writes a template ~/.zshrc when none exists, which stow would refuse.
# The guest keeps its own ~/.ssh/config, restored from backup, never the workstation one.
stow --no-folding --restow --ignore='^/\.ssh' -d "$DOT" -t "$HOME" "${STOW_PACKAGES[@]}"
systemctl --user daemon-reload

log "oh-my-zsh and plugins"
[[ -d $HOME/.oh-my-zsh ]] ||
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
for plugin in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
  dest=$HOME/.oh-my-zsh/custom/plugins/${plugin#*/}
  [[ -d $dest ]] || git clone --depth 1 "https://github.com/$plugin" "$dest"
done

log "done"
cat <<EOF
Toolchain and dotfiles are in place. Log out and back in for the docker group
and zsh. Then run:  $DOT/rebuild-wizard.sh
EOF
