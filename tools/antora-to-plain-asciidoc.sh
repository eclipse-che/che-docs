#!/usr/bin/env bash
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Exit on any error
set -e

# Variables for the project
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Variables for SOURCE
SOURCE_SRC="${SCRIPT_DIR%tools*}modules"
SOURCE_GUIDES="administration-guide end-user-guide"

# Variables for DESTINATION
DESTINATION_ROOT_DIR="${SCRIPT_DIR%tools*}build/plain-asciidoc"
DESTINATION_TEMPLATES_DIR="${DESTINATION_ROOT_DIR}/templates"

mkdir -p "$DESTINATION_TEMPLATES_DIR"

for GUIDE in ${SOURCE_GUIDES}
do
  # Generate title, copy topics, examples and images.
  SOURCE_GUIDE="${SOURCE_SRC}/${GUIDE}"
  DESTINATION_DIR="${DESTINATION_ROOT_DIR}/${GUIDE}"
  DESTINATION_TITLE="${DESTINATION_DIR}/index.adoc"
  DESTINATION_TOPICS_DIR="${DESTINATION_DIR}/topics"
  DESTINATION_EXAMPLES_DIR="${DESTINATION_TOPICS_DIR}/examples"
  DESTINATION_IMAGES_DIR="${DESTINATION_DIR}/images"
  mkdir -p "${DESTINATION_TOPICS_DIR}" "${DESTINATION_EXAMPLES_DIR}" "${DESTINATION_IMAGES_DIR}"

  # Generate title.adoc from Antora navigation file"
  # Convert xref into include, and list depth into leveloffset
  sed -E "\
    s@xref:@include::topics/@;
    s@\*\*\*\*\* (.*)\]@\1leveloffset=+5]@;
    s@\*\*\*\* (.*)\]@\1leveloffset=+4]@;
    s@\*\*\* (.*)\]@\1leveloffset=+3]@;
    s@\*\* (.*)\]@\1leveloffset=+2]@;
    s@\* (.*)\]@\1leveloffset=+1]@;
    " "${SOURCE_GUIDE}/nav.adoc" > "${DESTINATION_TITLE}"

  # Copy topics, examples, and images
  # Remove old topics, but keep examples and images as they may mix content
  find "${DESTINATION_TOPICS_DIR}"  -maxdepth 1 -name '*.adoc' -exec rm {} +
  # shellcheck disable=SC2086
  cp ${VERBOSE} -t "${DESTINATION_TOPICS_DIR}"  "${SOURCE_GUIDE}/pages/"* "${SOURCE_GUIDE}/partials/"*
  # shellcheck disable=SC2086
  cp ${VERBOSE} -f -r -t "${DESTINATION_EXAMPLES_DIR}" "${SOURCE_GUIDE}/examples/"*
  # shellcheck disable=SC2086
  cp -R ${VERBOSE} -t "${DESTINATION_IMAGES_DIR}/" "${SOURCE_GUIDE}/images/"*
done

# Prepare convert xref to file name into xref to id
FILE_TO_ID_MAP=$(grep -ire '\[id="' "${DESTINATION_ROOT_DIR}"/*/topics/)
FILE_TO_ID=$(echo "$FILE_TO_ID_MAP" | sed -E 's@.?*/(.?*adoc).?*"(.?*)"\]@s#xref:\1#xref:\2#g;@')
FILE_TO_ID_CROSS=$(echo "$FILE_TO_ID_MAP" | sed -E 's@.?*/(.?*adoc).?*"(.?*)"\]@s#xref:(.?*):\1#link:{\\1-url}\2#g;@')

# Convert partial$ and example$ statements
SUBSTITUTIONS="s@partial\\\$@@g;
s@example\\\$@examples/@g;
${FILE_TO_ID}
${FILE_TO_ID_CROSS}
"

# Convert include statements using `partial$` and `example$`` in plain AsciiDoc include statements
shopt -s globstar nullglob
for file in "${DESTINATION_ROOT_DIR}"/**/*.adoc
do
  # Substitutions
  sed -E -i "${SUBSTITUTIONS}" "$file"
done

# Validate asciidoctor build
for GUIDE in ${SOURCE_GUIDES}
do
  asciidoctor -a project-context=che -a context=che "${DESTINATION_ROOT_DIR}/${GUIDE}/index.adoc"
done

# Validate xref and links
vale --config="${SCRIPT_DIR%tools*}.vale/styles/PlainAsciiDoc/.vale.ini" "${DESTINATION_ROOT_DIR}/"
