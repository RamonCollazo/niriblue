#!/usr/bin/env bash
set -euo pipefail

echo 'spawn-at-startup "noctalia"' >> /usr/share/doc/niri/default-config.kdl

mkdir -p /etc/skel/.config/niri
cp /usr/share/doc/niri/default-config.kdl /etc/skel/.config/niri/config.kdl

grep -q 'spawn-at-startup "noctalia"' /etc/skel/.config/niri/config.kdl
