#!/usr/bin/env bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Exit on any error
set -e

# Variables for the project
TOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOTDIR="${TOOLSDIR%tools*}"

find ${ROOTDIR}/modules/*/{partials,examples} -name '*.adoc' -exec \
  sed -i -f "${TOOLSDIR}/substitutions.sed" {} +
