#!/usr/bin/env bash
set -euo pipefail

fail=0
for update_file in */update.sh; do
  echo "::group::Running update script: $update_file"
  if ! bash "$update_file"; then
    echo "❌ Update script failed"
    fail=1
  fi
  echo "::endgroup::"
done

if [ "$fail" -ne 0 ]; then
  echo "One or more update scripts failed."
  exit 1
fi