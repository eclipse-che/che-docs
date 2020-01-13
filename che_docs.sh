#!/bin/sh
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

CURRENT_VERSION=""
RAW_CONTENT=""
NEWLINE=$'\n'
NEWLINEX2=$'\n\n'
TABLE_HEADER=",=== $NEWLINE Name,Default value, Description $NEWLINE"
TABLE_FOOTER=",==="
BUFF="= Che configuration properties $NEWLINEX2"


fetch_current_version() {
  CURRENT_VERSION=$(grep -ri "<version>" pom.xml | tail -n 1 |sed -e "s/^[ \t]*<version>\([^<]*\)<.*$/\1/")
  if [[ "$CURRENT_VERSION" == *-SNAPSHOT ]]; then
     CURRENT_VERSION="master"
  fi
}


fetch_conf_files_content() {
  CHE_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/che.properties"
  RAW_CONTENT=$(curl -s "$CHE_PROPERTIES_URL")
  MULTIUSER_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/multiuser.properties"
  RAW_CONTENT="$RAW_CONTENT $(curl -s "$MULTIUSER_PROPERTIES_URL")"
}

parse_content() {
  while read -r LINE
  do
    if [[ $LINE == '##'* ]]; then
      if [[ ! -z $TOPIC ]]; then
        BUFF="$BUFF$TABLE_FOOTER $NEWLINE $NEWLINE"  # topic changes, closing the table
      fi
      TOPIC="${LINE//#}"
      BUFF="$BUFF==${TOPIC} $NEWLINEX2$TABLE_HEADER $NEWLINE" # new topic and table header
    elif [[ $LINE == '#'* ]] && [[ ! -z $TOPIC ]]; then
      TRIM_LINE=${LINE//#}
      DESCR_BUFF="$DESCR_BUFF${TRIM_LINE/ /}" # collect all description lines into buffer
    elif [[ -z $LINE ]] && [[ ! -z $TOPIC ]]; then
      DESCR_BUFF=""                           # empty line separator = cleanup description and property
      KEY=""
      VALUE=""
    elif [[ ! -z $TOPIC ]]; then
      IFS=$'=' read KEY VALUE <<< $LINE
      BUFF="$BUFF $KEY,\"$VALUE\",\"${DESCR_BUFF//\"/\'}\" $NEWLINE"   # apply key value and description buffer
    fi
  done <<< $RAW_CONTENT
  echo "$BUFF" >> test.adoc
}

fetch_current_version
fetch_conf_files_content
parse_content
