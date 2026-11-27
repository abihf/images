#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

TAUTULLI_REPO="Tautulli/Tautulli"
TAUTULLI_VERSION="$(get_latest_github_release_tag "$TAUTULLI_REPO" true | sed 's/^v//')"
update_docker_arg "TAUTULLI_VERSION" "$TAUTULLI_VERSION"
echo "Updated Tautulli version to $TAUTULLI_VERSION"
