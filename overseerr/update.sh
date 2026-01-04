#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

REPO="sct/overseerr"
BRANCH="develop"

LATEST_COMMIT=$(get_latest_github_commit "$REPO" "$BRANCH")
update_docker_arg "OVERSEERR_COMMIT" "$LATEST_COMMIT"
echo "Latest commit on $REPO ($BRANCH): $LATEST_COMMIT"