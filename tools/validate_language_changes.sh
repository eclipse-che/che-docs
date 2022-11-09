#!/bin/sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -e
umask 002
info() {
  echo -e "\e[32mINFO $1"
}

# Get fresh vale styles if required
test -d .vale/styles/RedHat/ || vale sync

case $CI in
true)
  # Avoid error on GitHub: fatal: detected dubious ownership in repository at '/__w/che-docs/che-docs'
  git config --global --add safe.directory $(pwd)
  ;;
esac

BRANCH=origin/${GITHUB_BASE_REF:-main}

FILES=$(git diff --name-only --diff-filter=AM "$BRANCH")

info "Validating files changed in comparison to branch $BRANCH:"

set -x
# shellcheck disable=SC2086 (We want to split on spaces)
vale ${FILES}
