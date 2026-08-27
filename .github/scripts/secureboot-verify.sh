#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')/niriblue"
if [ "${GITHUB_EVENT_NAME}" = "pull_request" ]; then
  TAG="pr-${PR_NUMBER}-44"
elif [ "${GITHUB_REF_NAME}" = "main" ]; then
  TAG="latest"
else
  TAG="br-${GITHUB_REF_NAME}-44"
fi
IMG="${IMAGE}:${TAG}"
echo "Verifying secure boot signature of the kernel in ${IMG}"

podman pull "${IMG}"
CONTAINER=$(podman create "${IMG}" true)
trap 'podman rm -f "${CONTAINER}" >/dev/null 2>&1 || true' EXIT

KVER=$(podman run --rm "${IMG}" ls /usr/lib/modules)
echo "Kernel: ${KVER}"
podman cp "${CONTAINER}:/usr/lib/modules/${KVER}/vmlinuz" vmlinuz

curl -fsSL -o key1.der https://github.com/ublue-os/akmods/raw/main/certs/public_key.der
curl -fsSL -o key2.der https://github.com/ublue-os/akmods/raw/main/certs/public_key_2.der
openssl x509 -inform der -in key1.der -out key1.pem
openssl x509 -inform der -in key2.der -out key2.pem

sbverify --list vmlinuz
sbverify --cert key1.pem vmlinuz || sbverify --cert key2.pem vmlinuz
