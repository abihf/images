#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

SONARR_REPO="Sonarr/Sonarr"
SONARR_BRANCH="v5-develop"
SONARR_COMMIT=$(get_latest_github_commit "$SONARR_REPO" "$SONARR_BRANCH")
SONARR_COMMIT_COUNT=$(get_number_of_commits "$SONARR_REPO" "$SONARR_COMMIT")
update_docker_arg "SONARR_COMMIT" "${SONARR_COMMIT}"
update_docker_arg "SONARR_COMMIT_COUNT" "${SONARR_COMMIT_COUNT}"
update_docker_arg "SONARR_BRANCH" "${SONARR_BRANCH}"
echo "Latest Sonarr commit: $SONARR_COMMIT ($SONARR_COMMIT_COUNT) on $SONARR_REPO ($SONARR_BRANCH)"