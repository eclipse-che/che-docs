#!/bin/bash
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -o pipefail

CURRENT_VERSION=""
RAW_CONTENT=""
NEWLINE=$'\n'
NEWLINEx2="$NEWLINE$NEWLINE"
TABLE_HEADER="$NEWLINEx2,=== $NEWLINE Environment Variable Name,Default value, Description $NEWLINE"
TABLE_FOOTER=",=== $NEWLINEx2"
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")/.." ; pwd -P )
BUFF=""
OUTPUT_PATH="$PARENT_PATH/src/main/pages/che-7/installation-guide/examples/system-variables.adoc"

fetch_current_version() {
  echo "Trying to read current product version from pom.xml..." >&2
  CURRENT_VERSION=$(grep -ri "<version>" $PARENT_PATH/pom.xml | tail -n 1 |sed -e "s/^[ \t]*<version>\([^<]*\)<.*$/\1/")
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read version from pom.xml" >&2
    exit 1
  fi
  if [[ "$CURRENT_VERSION" == *-SNAPSHOT ]]; then
     CURRENT_VERSION="master"
  fi
  echo "Detected version: $CURRENT_VERSION" >&2
}


fetch_conf_files_content() {
  echo "Fetching property files content from GitHub..." >&2
  CHE_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/che.properties"
  RAW_CONTENT=$(curl -sf "$CHE_PROPERTIES_URL")
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read che.properties from URL $CHE_PROPERTIES_URL" >&2
    exit 1
  fi
  MULTIUSER_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/multiuser.properties"
  RAW_CONTENT="$RAW_CONTENT $(curl -sf "$MULTIUSER_PROPERTIES_URL")"
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read multiuser.properties from URL $MULTIUSER_PROPERTIES_URL" >&2
    exit 1
  fi
  echo "Fetching content done. Trying to parse it." >&2
}

parse_content() {
  while read -r LINE
  do
    if [[ $LINE == '##'* ]]; then                       # line starting with two or more #s means new topic is started
      if [[ -n $TOPIC ]]; then
        BUFF="$BUFF$TABLE_FOOTER"                       # topic changes, closing the table
      fi
      TOPIC="${LINE//#}"                                # read topic, stripping #s
      TOPIC="${TOPIC/ }"                                # trim first space
      echo "   Found begin of topic: $TOPIC" >&2
      BUFF="$BUFF.${TOPIC} $TABLE_HEADER $NEWLINE"      # new topic and table header
    elif [[ $LINE == '#'* ]] && [[ -n $TOPIC ]]; then   # line starting with single # means property description (can be multi-line)
      TRIM_LINE=${LINE/\#}                              # read description, stripping first #
      DESCR_BUFF="$DESCR_BUFF${TRIM_LINE}"              # collect all description lines into buffer
    elif [[ -z $LINE ]] && [[ -n $TOPIC ]]; then
      DESCR_BUFF=""                                     # empty line is a separator -> cleanup description and property name + value
      KEY=""
      VALUE=""
    elif [[ -n $TOPIC ]]; then                          # non-empty line after any topic that doesn't start with # -> treat as property line
      IFS=$'=' read -r KEY VALUE <<< "$LINE"            # property split into key and value
      ENV=${KEY^^}                                      # capitalize property name
      ENV="\`+${ENV//_/__}+\`"                          # replace single underscores with double
      ENV=${ENV//./_}                                   # replace dots with single underscore
      VALUE="\`+${VALUE}+\`"                            # make sure asciidoc doesn't mix it up with attributes
      DESCR_BUFF="$(sed 's| {\([^}]*\)}| `+{\1}+`|g' <<< $DESCR_BUFF)"    # make sure asciidoc doesn't mix it up with attributes
      DESCR_BUFF="$(sed 's|\${\([^}]*\)}|$++{\1}++|g' <<< $DESCR_BUFF)"   # make sure asciidoc doesn't mix it up with attributes
      DESCR_BUFF="$(sed 's|\(Eclipse \)\?\bChe\b|{prod-short}|g' <<< $DESCR_BUFF)"   # (Eclipse) Che -> {prod-short}
      DESCR_BUFF="${DESCR_BUFF/ }"                      # trim first space
      BUFF="$BUFF $ENV,\"$VALUE\",\"${DESCR_BUFF//\"/\'}\" $NEWLINE"   # apply key value and description buffer
    fi
  done <<< "$RAW_CONTENT"
  BUFF="$BUFF$TABLE_FOOTER"                             # close last table
  echo "$BUFF" > $OUTPUT_PATH                           # flush buffer into file
  echo "Processing done. Output file is $OUTPUT_PATH" >&2
}

fetch_current_version
fetch_conf_files_content
parse_content
