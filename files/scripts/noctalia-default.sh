#!/usr/bin/env bash
set -euo pipefail

echo 'spawn-at-startup "noctalia"' >> /usr/share/doc/niri/default-config.kdl

grep -q 'spawn-at-startup "noctalia"' /usr/share/doc/niri/default-config.kdl
