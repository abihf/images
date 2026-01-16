#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

PKGBUILD="$(curl -sL https://github.com/archlinux/aur/raw/refs/heads/plex-media-server-plexpass/PKGBUILD)"
PLEX_VERSION=$(echo "$PKGBUILD" | grep -E '^pkgver=' | cut -d"=" -f2)
PLEX_PKG_SUM=$(echo "$PKGBUILD" | grep -E '^_pkgsum=' | cut -d"=" -f2)
update_docker_arg "PLEX_VERSION" "$PLEX_VERSION"
update_docker_arg "PLEX_PKG_SUM" "$PLEX_PKG_SUM"
echo "Latest Plex Version: $PLEX_VERSION"