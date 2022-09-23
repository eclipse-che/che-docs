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
id
ls -ltr
umask 002
./tools/checluster_docs_gen.sh
./tools/environment_docs_gen.sh
./tools/create_architecture_diagrams.py
CI=true antora generate antora-playbook-for-development.yml --stacktrace --log-failure-level=warn
htmltest
./tools/detect-unused-content.sh
./tools/validate_language_changes.sh
./tools/antora-to-plain-asciidoc.sh
