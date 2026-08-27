#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(mktemp -d)"
ROOTFS="${WORK_DIR}/rootfs"
CONTAINER="gen-sbom-${RANDOM}-${RANDOM}"
trap 'podman container rm -f "${CONTAINER}" >/dev/null 2>&1 || true; rm -rf "${WORK_DIR}"' EXIT

podman pull "${IMAGE}@${DIGEST}"
podman container create --name "${CONTAINER}" "${IMAGE}@${DIGEST}" >/dev/null
mkdir -p "${ROOTFS}"
podman export "${CONTAINER}" | tar --no-same-owner -C "${ROOTFS}" -xf -

export SYFT_PARALLELISM="${SYFT_PARALLELISM:-$(($(nproc) * 2))}"
syft scan --source-name "${IMAGE}" "dir:${ROOTFS}" -o spdx-json=sbom.spdx.json
du -sh sbom.spdx.json
