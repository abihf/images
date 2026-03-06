#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

NAVIDROME_REPO="navidrome/navidrome"
NAVIDROME_VERSION="$(get_latest_github_release_tag "$NAVIDROME_REPO" | sed 's/^v//')"
update_docker_arg "NAVIDROME_VERSION" "$NAVIDROME_VERSION"
echo "Updated Navidrome version to $NAVIDROME_VERSION"
