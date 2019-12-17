#!/bin/sh
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -e

# Detect presence of podman. Fallback to docker
RUNNER="$(command -v podman 2>/dev/null || command -v docker)"

case "${RUNNER}" in
  *podman)
    echo "Using $RUNNER."
    [ "$(find src/main/_site -user root -print -prune -o -prune 2>/dev/null)" ] && \
      echo "Previous build was probably created with docker. We need root privileges to delete it." && \
      sudo rm -rf src/main/_site/ 
    ;;
  *docker)
    echo "The preferred runner podman is not installed. Using fallback runner $RUNNER."
    ;;
  *)
    echo "No runner detected. Please install podman."
    ;;
esac

SRC_PATH="$(pwd)/src/main"

case "$1" in
  -prod)
    echo "Building for production (publishing on eclipse.org/che/docs/). To preview"
    echo "the docs locally, run the script ($0) without the '-prod' option."
    $RUNNER run --rm \
      -v "${SRC_PATH}":/che-docs:Z \
      quay.io/eclipse/che-docs \
      sh -c "cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-web.yml"
    ;;
  -war)
    echo "Building for embedding in Che (linking from the app). To preview"
    echo "the docs locally, run the script ($0) without the '-war' option."
    $RUNNER run --rm \
      -v "${SRC_PATH}":/che-docs:Z \
      quay.io/eclipse/che-docs \
      sh -c "cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-war.yml"
    ;;
  *)
    echo -e "Building and serving the docs for local preview.\n"
    echo -e "* To build for production testing (publishing on eclipse.org/che/docs/),"
    echo "  run the script with the '-prod' option:"
    echo -e "  $0 -prod\n"
    echo -e "* To build for embedding in Che (linking from the app),"
    echo "  run the script with the '-war' option:"
    echo -e "  $0 -war\n"
    $RUNNER run --rm -ti \
      -p 35729:35729 -p 4000:4000 \
      -v "${SRC_PATH}":/che-docs:Z \
      quay.io/eclipse/che-docs \
      sh -c "cd /che-docs && jekyll clean && jekyll serve --livereload -H 0.0.0.0 --trace"
  ;;
esac
