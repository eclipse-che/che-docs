#!/bin/bash

# Exit on any error
set -e

# This is a configuration parameters that can be che or crwctl
PROJECT_CONTEXT=${PROJECT_CONTEXT:-che}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCS_PROJECT_PATH=$SCRIPT_DIR/..

# we need to move it to make find print relative paths
pushd "$DOCS_PROJECT_PATH/modules" > /dev/null
readarray -d '' modules < <(find . -mindepth 1 -maxdepth 1 -type d -print0)

unused_images=""
for module in "${modules[@]}"
do
    pushd "$module" > /dev/null

    if [ ! -d "./images" ]; then        
        # This module does not images"
        popd > /dev/null
        continue
    fi

    readarray -d '' images < <(find "images" -name '*.png' -print0)
    for image in "${images[@]}"
    do
        #`../` instead of `images/` is used in the documentation references
        image=${image#"images/"}
        image_with_che_context="${image/che/{project-context\}}"
        image_with_crw_context="${image/${PROJECT_CONTEXT}/{project-context\}}"
        if ! grep -q -r "$image" . && ! grep -q -r "$image_with_che_context" . && ! grep -q -r "$image_with_crw_context" . ; then
            unused_images="$unused_images\n$image"
        fi
    done

    popd > /dev/null
done

popd > /dev/null

if [[ "$unused_images" ]]; then
    echo "!!! The following images are not used in their modules."
    echo "!!! Remove them to fix the issue."
    echo -e "${unused_images}"
    exit 1
else
    echo "All images have references in their the modules."
fi
