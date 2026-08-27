#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')/niriblue"
DIGEST=$(skopeo inspect --format '{{.Digest}}' "docker://${IMAGE}:latest")
echo "image=${IMAGE}" >> "$GITHUB_OUTPUT"
echo "digest=${DIGEST}" >> "$GITHUB_OUTPUT"
