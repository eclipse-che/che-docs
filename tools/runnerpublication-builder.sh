#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Detect available runner for containers
if command -v podman > /dev/null
  then RUNNER=podman
elif command -v docker > /dev/null
  then RUNNER=docker
else echo "No installation of podman or docker found in the PATH" ; exit 1
fi

# Fail on errors and display commands
set -ex

# Setting same memory limit as in JenkinsFile

${RUNNER} run --rm -ti --memory 512m \
  --name che-docs-publication \
  -v "$PWD:/projects:z" -w /projects \
  --entrypoint="./tools/publication-builder.sh" \
  -p 4000:4000 -p 35729:35729 \
  "${CHE_DOCS_IMAGE:-quay.io/eclipse/che-docs}"
