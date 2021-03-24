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

echo "Run linkchecker on a running che-docs container"

if command -v podman
  then RUNNER=podman
elif command -v docker
  then RUNNER=docker
else echo "No installation of podman or docker found in the PATH" ; exit 1
fi

# ${RUNNER} exec -ti che-docs "./tools/linkchecker.sh"
${RUNNER} run --rm -ti \
  --name che-docs-linkchecker \
  -v "$PWD:/projects:Z" -w /projects \
  --entrypoint="./tools/linkchecker.sh" \
  "${CHE_DOCS_IMAGE:-quay.io/eclipse/che-docs}"