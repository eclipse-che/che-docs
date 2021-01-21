#!/usr/bin/env sh
set -ex

podman run --rm -ti \
  -v "$(pwd):/test:Z" \
  "${CHE_DOCS_IMAGE:-wjdp/htmltest}" \
  -c .htmltest.yml
