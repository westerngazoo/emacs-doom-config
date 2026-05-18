#!/usr/bin/env bash
# Symlinks the configs in dotfiles/ into the locations their apps expect.
# Safe to re-run; existing non-symlink files are backed up with a timestamp.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$REPO/dotfiles"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.backup-$STAMP"
    echo "backed up $dst -> $dst.backup-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
}

link "$DOT/ghostty-config" "$HOME/.config/ghostty/config"
link "$DOT/starship.toml"  "$HOME/.config/starship.toml"
link "$DOT/zshrc"          "$HOME/.zshrc"

# macOS-only: Aerospace window manager
if [[ "$(uname)" == "Darwin" ]]; then
  link "$DOT/aerospace.toml"   "$HOME/.config/aerospace/aerospace.toml"
  link "$DOT/restore-c32.sh"   "$HOME/.config/aerospace/restore-c32.sh"
  chmod +x "$HOME/.config/aerospace/restore-c32.sh"
fi

# org-roam directory (needed to avoid errors on Emacs reload)
mkdir -p "$HOME/org/roam"

# Ghostty cursor shaders referenced by ghostty-config
if [ ! -d "$HOME/.config/ghostty/shaders" ]; then
  git clone --depth 1 https://github.com/KroneCorylus/ghostty-shader-playground \
    "$HOME/.config/ghostty/shaders" && echo "cloned ghostty shaders"
fi

echo "done — restart your shell and reload Ghostty."
