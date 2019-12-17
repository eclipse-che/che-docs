#!/bin/sh
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

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

printf "${BOLD}Building${NC} ${BLUE}eclipse/che-docs${NC} Che documentation ${BLUE}docker image${NC}\n"
$RUNNER build -t quay.io/eclipse/che-docs .
if $RUNNER build -t quay.io/eclipse/che-docs .; then
  printf "${BOLD}Build${NC} ${BLUE}quay.io/eclipse/che-docs${NC} ${GREEN}[OK]${NC}\n"
else
  printf "${BOLD}Build${NC} ${BLUE}quay.io/eclipse/che-docs${NC} ${RED}[Failure]${NC}\n"
fi
