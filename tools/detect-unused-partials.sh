#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Exit on any error
set -e

# This is a configuration parameters that can be che or crwctl
PROJECT_CONTEXT=${PROJECT_CONTEXT:-che}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCS_PROJECT_PATH=$SCRIPT_DIR/..

# we need to move it to make find print relative paths
pushd "$DOCS_PROJECT_PATH/modules" > /dev/null
readarray -d '' modules < <(find . -mindepth 1 -maxdepth 1 -type d -print0)

unused_partials=""
for module in "${modules[@]}"
do
    pushd "$module" > /dev/null

    if [ ! -d "./partials" ]; then        
        # This module does not have partials"
        popd > /dev/null
        continue
    fi

    readarray -d '' partials < <(find "partials" -name '*.adoc' -print0)
    for partial in "${partials[@]}"
    do
        #`../` instead of `partials/` is used in the documentation references
        partial=${partial#"partials/"}
        partial_with_che_context="${partial/che/{project-context\}}"
        partial_with_crw_context="${partial/${PROJECT_CONTEXT}/{project-context\}}"
        if ! grep -q -r "$partial" . && ! grep -q -r "$partial_with_che_context" . && ! grep -q -r "$partial_with_crw_context" . ; then
            unused_partials="$unused_partials\n$partial"
        fi
    done

    popd > /dev/null
done

popd > /dev/null

if [[ "$unused_partials" ]]; then
    echo "!!! The following partials are not used in their modules."
    echo "!!! Remove them to fix the issue."
    echo -e "${unused_partials}"
    exit 1
else
    echo "All partials have references in the modules."
fi
