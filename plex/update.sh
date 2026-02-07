#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"
PLEX_PASS=${PLEX_PASS:-xxxxxxxxxxxxxxxxxxxx}

PLEX_URL=$(curl -L \
  --header "X-Plex-Token:$PLEX_PASS" \
  'https://plex.tv/api/downloads/5.json?channel=plexpass' \
  | jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64" and .distro == "debian") | .url')
update_docker_arg "PLEX_URL" "$PLEX_URL"
echo "Latest Plex URL: $PLEX_URL"