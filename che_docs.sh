#!/bin/sh
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
BUFF="= Che configuration properties $NEWLINEx2"

fetch_current_version() {
  CURRENT_VERSION=$(grep -ri "<version>" pom.xml | tail -n 1 |sed -e "s/^[ \t]*<version>\([^<]*\)<.*$/\1/")
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read version from pom.xml" >&2
    exit 1
  fi
  if [[ "$CURRENT_VERSION" == *-SNAPSHOT ]]; then
     CURRENT_VERSION="master"
  fi
}


fetch_conf_files_content() {
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
}

parse_content() {
  while read -r LINE
  do
    if [[ $LINE == '##'* ]]; then
      if [[ ! -z $TOPIC ]]; then
        BUFF="$BUFF$TABLE_FOOTER"                   # topic changes, closing the table
      fi
      TOPIC="${LINE//#}"                            # read topic stripping #-s
      BUFF="$BUFF==${TOPIC} $TABLE_HEADER $NEWLINE" # new topic and table header
    elif [[ $LINE == '#'* ]] && [[ ! -z $TOPIC ]]; then
      TRIM_LINE=${LINE//#}                          # read description stripping #-s
      DESCR_BUFF="$DESCR_BUFF${TRIM_LINE/ /}"       # collect all description lines into buffer
    elif [[ -z $LINE ]] && [[ ! -z $TOPIC ]]; then
      DESCR_BUFF=""                                 # empty line is a separator = cleanup description and property name + value
      KEY=""
      VALUE=""
    elif [[ ! -z $TOPIC ]]; then
      IFS=$'=' read KEY VALUE <<< $LINE             # property split into key and value
      ENV=${KEY^^}                                  # capitalize property name
      ENV="+${ENV//_/__}+"                          # replace single underscores with double
      ENV=${ENV//./_}                               # replace dots with single underscore
      BUFF="$BUFF $ENV,\"$VALUE\",\"${DESCR_BUFF//\"/\'}\" $NEWLINE"   # apply key value and description buffer
    fi
  done <<< $RAW_CONTENT
  echo "$BUFF" > $1
}

if [ $# -eq 0 ]; then
  echo "Error: output filename required."
  exit 1
fi


fetch_current_version
fetch_conf_files_content
parse_content $1
