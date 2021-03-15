#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -ex

LIVERELOAD=true
export LIVERELOAD

installandrungulp() { # Install gulp when not present in $PATH
echo "--modules-folder /tmp/node_modules" > /projects/.yarnrc
export HOME=/projects
export NODE_PATH=/tmp/node_modules
yarn add gulp gulp-cli gulp-connect
$NODE_PATH/gulp/bin/gulp.js
}

command -v gulp || installandrungulp && gulp
