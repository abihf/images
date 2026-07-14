#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

RESTIC_REPO="restic/restic"
RESTIC_VERSION="$(get_latest_github_release_tag "$RESTIC_REPO" | sed 's/^v//')"
update_docker_arg "RESTIC_VERSION" "$RESTIC_VERSION"
echo "Updated Restic version to $RESTIC_VERSION"