#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../utils.sh"

UBUNTU_TAG="26.10"

TOKEN="$(curl -fsSL "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/ubuntu:pull" | jq -r .token)"
DIGEST="$(curl -fsSI \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json" \
  "https://registry-1.docker.io/v2/library/ubuntu/manifests/${UBUNTU_TAG}" | \
  tr -d '\r' | awk -F': ' 'tolower($1) == "docker-content-digest" { print $2 }')"

if [[ "$DIGEST" != sha256:* ]]; then
  echo "Failed to fetch digest for ubuntu:${UBUNTU_TAG}" >&2
  exit 1
fi

update_docker_arg "UBUNTU_TAG" "$UBUNTU_TAG"
update_docker_arg "UBUNTU_DIGEST" "$DIGEST"

echo "Updated ubuntu-dev to ${UBUNTU_TAG}@${DIGEST}"
