#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

RADARR_REPO="Radarr/Radarr"
RADARR_VERSION="$(get_latest_github_release_tag "$RADARR_REPO" | sed 's/^v//')"
update_docker_arg "RADARR_VERSION" "$RADARR_VERSION"
echo "Updated Radarr version to $RADARR_VERSION"