#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

PAR2_REPO="animetosho/par2cmdline-turbo"
PAR2_BRANCH="turbo"
PAR2_COMMIT=$(get_latest_github_commit "$PAR2_REPO" "$PAR2_BRANCH")
update_docker_arg "PAR2_COMMIT" "$PAR2_COMMIT"
echo "Latest par2cmdline-turbo commit on $PAR2_REPO ($PAR2_BRANCH): $PAR2_COMMIT"

SABNZBD_REPO="sabnzbd/sabnzbd"
SABNZBD_BRANCH="develop"
SABNZBD_COMMIT=$(get_latest_github_commit "$SABNZBD_REPO" "$SABNZBD_BRANCH")
update_docker_arg "SABNZBD_COMMIT" "$SABNZBD_COMMIT"
echo "Latest SABnzbd commit on $SABNZBD_REPO ($SABNZBD_BRANCH): $SABNZBD_COMMIT"