#!/usr/bin/env bash
set -euo pipefail

df -h /
sudo rm -rf /usr/local/lib/android /usr/share/dotnet /opt/ghc /usr/local/.ghcup /usr/local/share/boost /opt/hostedtoolcache/CodeQL
sudo docker image prune -af >/dev/null 2>&1 || true
df -h /
