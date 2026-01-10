#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

PROWLARR_REPO="Prowlarr/Prowlarr"
PROWLARR_VERSION="$(get_latest_github_release_tag "$PROWLARR_REPO" | sed 's/^v//')"
update_docker_arg "PROWLARR_VERSION" "$PROWLARR_VERSION"
echo "Updated Prowlarr version to $PROWLARR_VERSION"
