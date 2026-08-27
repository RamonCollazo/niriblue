#!/usr/bin/env bash
set -euo pipefail

TAG="build-$(date -u +%Y%m%d)-r${GITHUB_RUN_NUMBER}"
PREV=$(gh release list --repo "${GITHUB_REPOSITORY}" --limit 1 --json tagName --jq '.[0].tagName' || true)

{
  echo "Image: \`${IMAGE}@${DIGEST}\`"
  echo
  if [ -n "$PREV" ] && gh release download "$PREV" --repo "${GITHUB_REPOSITORY}" --pattern pkgs.txt --output prev-pkgs.txt 2>/dev/null; then
    echo "## Package changes since $PREV"
    echo '```'
    diff prev-pkgs.txt pkgs.txt | grep -E '^[<>]' | sed 's/^</removed:/; s/^>/added:  /' || echo "no package changes"
    echo '```'
  else
    echo "First tracked release; package list attached."
  fi
} > notes.md

gh release create "$TAG" --repo "${GITHUB_REPOSITORY}" --title "$TAG" --notes-file notes.md pkgs.txt sbom.spdx.json
