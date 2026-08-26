#!/usr/bin/env bash
set -oue pipefail

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
INCOMING_KERNEL_VERSION="$(basename -s .rpm $(ls /tmp/rpms/kernel/kernel-[0-9]*.rpm 2>/dev/null | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//'))"

echo "Current kernel: $QUALIFIED_KERNEL"
echo "Incoming kernel: $INCOMING_KERNEL_VERSION"

if [[ "$INCOMING_KERNEL_VERSION" != "$QUALIFIED_KERNEL" ]]; then
    for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
        if rpm -q $pkg >/dev/null 2>&1; then
            rpm --erase $pkg --nodeps
        fi
    done
    dnf -y install \
        /tmp/rpms/kernel/kernel-[0-9]*.rpm \
        /tmp/rpms/kernel/kernel-core-*.rpm \
        /tmp/rpms/kernel/kernel-modules-*.rpm
else
    cd /tmp
    rpm2cpio /tmp/rpms/kernel/kernel-core-*.rpm | cpio -idmv
    cp ./lib/modules/*/vmlinuz /usr/lib/modules/*/vmlinuz
    cd /
fi
