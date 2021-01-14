#!/usr/bin/env sh
set -ex

podman run --rm -ti \
  --name che-docs \
  -v $PWD:/projects:Z -w /projects \
  --entrypoint="./tools/preview.sh" \
  -p 4000:4000 -p 35729:35729 \
  ${CHE_DOCS_IMAGE:-quay.io/eclipse/che-docs}
