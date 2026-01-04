#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

BOOST_REPO="boostorg/boost"
BOOST_VERSION_TAG=$(get_latest_github_release_tag "$BOOST_REPO")
update_docker_arg "BOOST_TAG" "${BOOST_VERSION_TAG}"
echo "Latest Boost version: $BOOST_VERSION_TAG"

LIBBT_REPO="arvidn/libtorrent"
LIBBT_BRANCH="RC_2_0"
LIBBT_COMMIT=$(get_latest_github_commit "$LIBBT_REPO" "$LIBBT_BRANCH")
update_docker_arg "LIBBT_COMMIT" "$LIBBT_COMMIT"
echo "Latest libtorrent commit on $LIBBT_REPO ($LIBBT_BRANCH): $LIBBT_COMMIT"

QBT_REPO="qbittorrent/qBittorrent"
QBT_BRANCH="v5_1_x"
QBT_COMMIT=$(get_latest_github_commit "$QBT_REPO" "$QBT_BRANCH")
update_docker_arg "QBT_COMMIT" "$QBT_COMMIT"
echo "Latest qBittorrent commit on $QBT_REPO ($QBT_BRANCH): $QBT_COMMIT"