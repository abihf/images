#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

SONARR_REPO="Sonarr/Sonarr"
SONARR_VERSION="$(get_latest_github_release_tag "$SONARR_REPO" | sed 's/^v//')"
update_docker_arg "SONARR_VERSION" "$SONARR_VERSION"
echo "Updated Sonarr version to $SONARR_VERSION"
