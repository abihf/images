#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

ADGUARDHOME_REPO="AdguardTeam/AdGuardHome"
ADGUARDHOME_BRANCH="master"
ADGUARDHOME_COMMIT=$(get_latest_github_commit "$ADGUARDHOME_REPO" "$ADGUARDHOME_BRANCH")
update_docker_arg "ADGUARDHOME_COMMIT" "$ADGUARDHOME_COMMIT"
echo "Latest AdGuardHome commit on $ADGUARDHOME_REPO ($ADGUARDHOME_BRANCH): $ADGUARDHOME_COMMIT"