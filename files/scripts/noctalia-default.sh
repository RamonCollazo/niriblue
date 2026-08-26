#!/usr/bin/env bash
set -euo pipefail

sed -i 's/spawn-at-startup "waybar"/spawn-at-startup "noctalia"/' \
  /usr/share/doc/niri/default-config.kdl

grep -q 'spawn-at-startup "noctalia"' /usr/share/doc/niri/default-config.kdl
