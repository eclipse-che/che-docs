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
set -ex
umask 002
CI=true antora generate antora-playbook-for-development.yml --stacktrace --log-failure-level=warn
htmltest
