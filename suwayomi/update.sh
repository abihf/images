#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

SUWAYOMI_REPO="Suwayomi/Suwayomi-Server-preview"
SUWAYOMI_VERSION="$(get_latest_github_release_tag "$SUWAYOMI_REPO" | sed 's/^v//')"
update_docker_arg "SUWAYOMI_VERSION" "$SUWAYOMI_VERSION"

SUWAYOMI_DOCKER_REPO="Suwayomi/Suwayomi-Server-docker"
SUWAYOMI_DOCKER_COMMIT="$(get_latest_github_commit "$SUWAYOMI_DOCKER_REPO" main)"
update_docker_arg "SUWAYOMI_DOCKER_COMMIT" "$SUWAYOMI_DOCKER_COMMIT"

echo "Updated Suwayomi to $SUWAYOMI_VERSION (docker scripts $SUWAYOMI_DOCKER_COMMIT)"
