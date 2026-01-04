#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

SPEEDTEST_REPO="librespeed/speedtest-rust"
SPEEDTEST_BRANCH="master"
SPEEDTEST_COMMIT=$(get_latest_github_commit "$SPEEDTEST_REPO" "$SPEEDTEST_BRANCH")
update_docker_arg "SPEEDTEST_COMMIT" "$SPEEDTEST_COMMIT"
echo "Latest speedtest-rust commit on $SPEEDTEST_REPO ($SPEEDTEST_BRANCH): $SPEEDTEST_COMMIT"