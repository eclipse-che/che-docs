#!/usr/bin/env sh
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fail on errors
set -e
umask 002

CHE_DOCS_IMAGE=che-docs-devel
export CHE_DOCS_IMAGE

# Detect available runner
if [ -z ${RUNNER+x} ]; then
  if command -v podman >/dev/null; then
    RUNNER=podman
  elif command -v docker >/dev/null; then
    RUNNER=docker
  else
    echo "No installation of podman or docker found in the PATH"
    exit 1
  fi
fi

# Display commands
set -x

$RUNNER build -t "${CHE_DOCS_IMAGE}" .

# --volume:
# The z option tells Podman that two containers share the volume content.
# --user="root": workaround for docker running in the GitHub workflow

${RUNNER} run --rm -ti \
  --entrypoint="./tools/build.sh" \
  --name che-docs-devel \
  --user="root" \
  --volume="$PWD:/projects:z" \
  --workdir="/projects" \
  -p 4000:4000 -p 35729:35729 \
  "${CHE_DOCS_IMAGE}"
