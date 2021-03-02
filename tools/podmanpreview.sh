#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -ex

if command -v podman
  then RUNNER=podman
elif command -v docker
  then RUNNER=docker
else echo "No installation of podman or docker found in the PATH" ; exit 1
fi

${RUNNER} run --rm -ti \
  --name che-docs \
  -v "$PWD:/projects:Z" -w /projects \
  --entrypoint="./tools/preview.sh" \
  -p 4000:4000 -p 35729:35729 \
  "${CHE_DOCS_IMAGE:-quay.io/eclipse/che-docs}"
