#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fail on errors and display commands
set -ex

git branch -Df publication || true
git checkout --orphan publication
git add build Jenkinsfile
git commit -m "publication: $(/bin/date -Iminutes)"
git push --force origin publication
