#!/usr/bin/env bash
set -euo pipefail

sudo podman pull "${IMAGE}@${DIGEST}"
CID=$(sudo podman create "${IMAGE}@${DIGEST}" /bin/true)
MNT=$(sudo podman mount "$CID")

sudo /usr/local/bin/syft scan "dir:${MNT}" --select-catalogers rpm -o spdx-json=sbom.spdx.json
sudo chown "$(id -u):$(id -g)" sbom.spdx.json

sudo podman unmount "$CID" >/dev/null
sudo podman rm "$CID" >/dev/null
