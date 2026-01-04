#!/usr/bin/env bash
set -euo pipefail

for update_file in */update.sh; do
  echo "::group::Running update script: $update_file"
  bash "$update_file" || true
  echo "::endgroup::"
done