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
umask 002
info() {
  echo -e "\e[32mINFO $1"
}
error() {
  echo -e "\e[31mERROR $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOCS_PROJECT_PATH=$SCRIPT_DIR/..

# we need to move it to make find print relative paths
pushd "$DOCS_PROJECT_PATH/modules" >/dev/null
readarray -d '' modules < <(find . -mindepth 1 -maxdepth 1 -type d -print0)

unused_images=""
for module in "${modules[@]}"; do
  pushd "$module" >/dev/null
  relative_dir="modules${module#.}"

  if [ ! -d "./images" ]; then
    # This module does not have images"
    popd >/dev/null
    continue
  fi

  readarray -d '' images < <(find "images" -type f -not -name .placeholder -print0)
  for image in "${images[@]}"; do
    #`../` instead of `images/` is used in the documentation references
    image=${image#"images/"}
    image_with_che_context="${image/che/{project-context\}}"
    image_with_downstream_context="${image/devspaces/{project-context\}}"
    if ! grep -q -r "$image" . && ! grep -q -r "$image_with_che_context" . && ! grep -q -r "$image_with_downstream_context" .; then
      unused_images="$unused_images  - $relative_dir/$image\n"
    fi
  done

  popd >/dev/null
done

unused_pages=""
for module in "${modules[@]}"; do
  pushd "$module" >/dev/null
  relative_dir="modules${module#.}"

  if [ ! -d "./pages" ]; then
    # This module does not have pages"
    popd >/dev/null
    continue
  fi

  readarray -d '' pages < <(find "pages" -name '*.adoc' -print0)
  for page in "${pages[@]}"; do
    page=${page#pages/}
    if ! grep -q "$page" nav.adoc; then
      unused_pages="$unused_pages  - $relative_dir/$page\n"
    fi
  done

  popd >/dev/null
done

unused_partials=""
for module in "${modules[@]}"; do
  pushd "$module" >/dev/null
  relative_dir="modules${module#.}"

  if [ ! -d "./partials" ]; then
    # This module does not have partials"
    popd >/dev/null
    continue
  fi

  readarray -d '' partials < <(find "partials" -name '*.adoc' -print0)
  for partial in "${partials[@]}"; do
    #`../` instead of `partials/` is used in the documentation references
    partial=${partial#"partials/"}
    partial_with_che_context="${partial/che/{project-context\}}"
    partial_with_devspaces_context="${partial/devspaces/{project-context\}}"
    if ! grep -q -r "$partial" . && ! grep -q -r "$partial_with_che_context" . && ! grep -q -r "$partial_with_devspaces_context" .; then
      unused_partials="$unused_partials  - $relative_dir/$partial\n"
    fi
  done

  popd >/dev/null
done

popd >/dev/null

if [[ "$unused_images" ]]; then
  error "The following images are not used in their modules. Remove the files or reference them in the content."
  echo -e "${unused_images}"
  exit_status=1
else
  info "All images have reference in the modules."
fi

if [[ "$unused_pages" ]]; then
  error "The following pages are not used in the navigation. Remove the files or reference them in the nav.adoc file."
  echo -e "${unused_pages}"
  exit_status=1
else
  info "All pages have reference in the navigation."
fi

if [[ "$unused_partials" ]]; then
  error "The following partials are not used in their module. Remove the files or include them in a page."
  echo -e "${unused_partials}"
  exit_status=1
else
  info "All partials have reference in the modules."
fi

exit $exit_status
