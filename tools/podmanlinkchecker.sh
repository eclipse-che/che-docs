#!/usr/bin/env sh
set -ex

echo "Run linkchecker on a running che-docs container"

podman exec -ti \
  che-docs \
  "./tools/linkchecker.sh" \
  