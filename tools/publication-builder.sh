#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Create group writeable files
umask 002

# Fail on errors and display commands
set -ex

# Build with Antora
CI=true antora generate publication-builder-antora-playbook.yml --stacktrace

# Remove this file that may break Eclipse Che website `index.php`
rm -f build/site/index.html 

# Add a custom redirect in the docs directory
cp tools/index.html build/site/docs/index.html

# Add required tools
cp tools/Jenkinsfile build/site/Jenkinsfile
cp tools/push-to-eclipse-repository.sh build/site/push-to-eclipse-repository.sh

# Validate internal links
htmltest --skip-external
