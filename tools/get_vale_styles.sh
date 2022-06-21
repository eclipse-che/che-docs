#!/usr/bin/env bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Download a fresh version of the RedHat and CheDocs Vale styles.

# Fail on errors
set -e
# New files will be group writeable (for local builds)
umask 002
ScriptDir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
RootDir="${ScriptDir%/tools*}"
StylesDir="${RootDir}/.github/styles"
# Create destination directory if required
mkdir --parents "${StylesDir}"
# Download a fresh version of the RedHat Vale style
wget --output-document="${StylesDir}/RedHat.zip" --quiet --timestamping  https://github.com/redhat-documentation/vale-at-red-hat/releases/latest/download/RedHat.zip
rm --force --recursive "${StylesDir}/RedHat"
unzip -q -d  "${StylesDir}" RedHat.zip
# Download a fresh version of the CheDocs Vale style
wget --output-document="${StylesDir}/CheDocs.zip" --quiet --timestamping https://github.com/eclipse-che/che-docs-vale-style/releases/latest/download/CheDocs.zip
rm --force --recursive "${StylesDir}/CheDocs"
unzip -q -d  "${StylesDir}" CheDocs.zip
echo 'INFO: Downloaded a fresh version of the Red Hat Vale style and configuration file.'
