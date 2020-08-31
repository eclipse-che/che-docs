#!/usr/bin/env bash

# Exit on any error
set -e

# Variables for the project
TOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOTDIR="${TOOLSDIR%tools*}"

find ${ROOTDIR}/modules/*/{partials,examples} -name '*.adoc' -exec \
  sed -i -f "${TOOLSDIR}/substitutions.sed" {} +
