#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

LIDARR_REPO="Lidarr/Lidarr"
LIDARR_VERSION="$(get_latest_github_release_tag "$LIDARR_REPO" true | sed 's/^v//')"
update_docker_arg "LIDARR_VERSION" "$LIDARR_VERSION"
echo "Updated Lidarr version to $LIDARR_VERSION"