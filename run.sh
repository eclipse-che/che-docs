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

usage() {
  echo "$0 [-h] [-prod] [-war] [-testadoc]
  OPTIONS:
    (no option)                     Building and serving the docs for local preview.
    -prod                           Building for production, to publish on eclipse.org/che/docs/.
    -war                            Building for embedding in Che, to link from the app.
    -newassembly <guide> <title>    Create a new assembly in guide <guide>, with title <title>
    -newconcept <guide> <title>     Create a new concept in guide <guide>, with title <title>
    -newprocedure <guide> <title>   Create a new procedure in guide <guide>, with title <title>
    -newreference <guide> <title>   Create a new reference in guide <guide>, with title <title>
    -test-adoc [<fileslist>]        Run test-adoc.sh on files (default: on all files)
    -vale [<fileslist>]             Run vale linter on files (default: on all files)
  VARIABLES:
     CHEDOCSIMAGE             Override the default container image.
  "
}

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

# Use the user defined container, else the default container.
IMAGE=${CHEDOCSIMAGE:-quay.io/eclipse/che-docs}

# Default mountmoint for the container
SRC_PATH="$(pwd)/src/main"

# Define the run command as a function (shellcheck recommendation)
runner() {
  # Pull the default container image, else assume the image is present.
  [ "${IMAGE}" = "quay.io/eclipse/che-docs" ] # && "${RUNNER}" pull "${IMAGE}"

  "${RUNNER}" run --rm -v "${SRC_PATH}":/che-docs:Z "$@"
}

run_newdoc() {
    shift
    SRC_PATH="$(pwd)/src/main/pages/che-7/${1}"
    shift
    TITLE="${*}"
    echo "Running newdoc in ${SRC_PATH} with option ${NATURE} ${TITLE}"
    runner "${IMAGE}" \
      bash -c "newdoc -C ${NATURE} ${TITLE}"
}

case "$1" in
  -h)
    usage
    ;;
  -prod)
    echo "Building for production (publishing on eclipse.org/che/docs/)."
    runner "${IMAGE}" \
      sh -c "cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-web.yml"
    ;;
  -war)
    echo "Building for embedding in Che (linking from the app)."
    runner "${IMAGE}" \
      sh -c "cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-war.yml"
    ;;
  -newassembly)
    NATURE="-a"
    run_newdoc "$@"
    ;;
  -newconcept)
    NATURE="-c"
    run_newdoc "$@"
    ;;
  -newprocedure)
    NATURE="-p"
    run_newdoc "$@"
    ;;
  -newreference)
    NATURE="-r"
    run_newdoc "$@"
    ;;
  -test-adoc)
    shift
    SRC_PATH="$(pwd)"
    FILES="${*:-src/main/pages/*/*/*.adoc}"
    echo "Running test-adoc.sh on ${FILES}"
    runner "${IMAGE}" \
      bash -c "test-adoc.sh ${FILES}"
    ;;
  -vale)
    shift
    SRC_PATH="$(pwd)"
    FILES="${*:-.}"
    echo "Running vale on ${FILES}"
    runner "${IMAGE}" \
      bash -c "vale ${FILES}"
    ;;
  *)
    echo "Building and serving the docs for local preview."
    runner -p 35729:35729 -p 4000:4000 "${IMAGE}" \
      sh -c "cd /che-docs && jekyll clean && jekyll serve --livereload -H 0.0.0.0 --trace"
  ;;
esac
