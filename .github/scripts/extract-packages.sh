#!/usr/bin/env bash
set -euo pipefail

jq -r '.packages[] | select(.versionInfo != null) | "\(.name) \(.versionInfo)"' sbom.spdx.json | sort -u > pkgs.txt
wc -l pkgs.txt
