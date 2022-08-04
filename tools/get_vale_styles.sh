#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fail on errors
set -e

# Get fresh Vale styles
mkdir --parents .vale/styles
cd .vale/styles || exit
rm -rf RedHat CheDocs
wget --quiet --timestamping https://github.com/redhat-documentation/vale-at-red-hat/releases/latest/download/RedHat.zip
unzip -q RedHat.zip
wget --quiet --timestamping https://github.com/eclipse-che/che-docs-vale-style/releases/latest/download/CheDocs.zip
unzip -q CheDocs.zip
echo "Downloaded fresh 'CheDocs' and 'RedHat' Vale styles"