#!/usr/bin/env bash

# Exit on any error
set -e

# Variables for the project
TOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOTDIR="${TOOLSDIR%tools*}"
TOPICSDIR="${ROOTDIR}src/main/pages/che-7"

for TOPIC_FILE in "${TOPICSDIR}"/**/*.adoc
do
sed -i -f "${TOOLSDIR}/substitutions.sed" "${TOPIC_FILE}"
done
