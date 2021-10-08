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

# Fetch all branches (on Jenkins)
git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch

CI=true antora generate antora-playbook-for-publication.yml --stacktrace
htmltest --skip-external
