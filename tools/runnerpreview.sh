#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Detect available runner
if command -v podman > /dev/null
  then RUNNER=podman
elif command -v docker > /dev/null
  then RUNNER=docker
else echo "No installation of podman or docker found in the PATH" ; exit 1
fi

# Fail on errors
set -e

# Pull the image unless using a container defined in environment variable
[ -z ${CHE_DOCS_IMAGE} ] && ${RUNNER} pull quay.io/eclipse/che-docs

# Display commands
set -x

${RUNNER} run --rm -ti \
  --name che-docs \
  -v "$PWD:/projects:z" -w /projects \
  --entrypoint="./tools/preview.sh" \
  -p 4000:4000 -p 35729:35729 \
  "${CHE_DOCS_IMAGE:-quay.io/eclipse/che-docs}"
