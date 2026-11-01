#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

SUWAYOMI_REPO="Suwayomi/Suwayomi-Server-preview"
SUWAYOMI_VERSION="$(get_latest_github_release_tag "$SUWAYOMI_REPO" | sed 's/^v//')"
update_docker_arg "SUWAYOMI_VERSION" "$SUWAYOMI_VERSION"

echo "Updated Suwayomi to $SUWAYOMI_VERSION"
