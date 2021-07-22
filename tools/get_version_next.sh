#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
PARENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit; pwd -P)
CURRENT_VERSION="$(yq -M '.asciidoc.attributes."prod-ver"' "$PARENT_PATH/antora.yml" | tr -d " '\"" ).x"
echo "$CURRENT_VERSION"
