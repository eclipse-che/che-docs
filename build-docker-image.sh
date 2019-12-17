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

printf "${BOLD}Building${NC} ${BLUE}eclipse/che-docs${NC} Che documentation ${BLUE}docker image${NC}\n"
docker build -t quay.io/eclipse/che-docs .
if docker build -t quay.io/eclipse/che-docs .; then
  printf "${BOLD}Build${NC} ${BLUE}quay.io/eclipse/che-docs${NC} ${GREEN}[OK]${NC}\n"
else
  printf "${BOLD}Build${NC} ${BLUE}quay.io/eclipse/che-docs${NC} ${RED}[Failure]${NC}\n"
fi
