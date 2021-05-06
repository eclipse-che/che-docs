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
TOOLS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" || return ; pwd -P )
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")/.." || return ; pwd -P )
OUTPUT_PATH="$PARENT_PATH/modules/installation-guide/partials"

usage() {
  echo "
  Usage: /${BASH_SOURCE[0]} [-h] [-f]  
  PURPOSE: Create draft reference files for new Che Server parameters.
  * Lookup for current version in antora-playbook.yml
  * Fetch the definitions of all Che Server parameters as defined in the che.properties and multiuser.properties files in the che repository.
  * Create draft reference files for new Che Server parameters.
  * If invoked with the -f option, force the generation of reference files for *all* parameters.
    OPTIONS:
      -h help
      -f force the generation of reference files for *all* parameters.
  "
  exit 0
}

run() {
  fetch_current_version
  fetch_conf_files_content
  parse_content
  create_unordered_assembly
}

fetch_current_version() {
  CURRENT_VERSION=""
  # Read current product version from $PARENT_PATH/antora-playbook.yml...
  CURRENT_VERSION=$(grep 'prod-ver:' "$PARENT_PATH/antora-playbook.yml" | cut -d: -f2 | sed  's/ //g')
  case $CURRENT_VERSION in
    '')
      echo "ERROR: Cannot read version from $PARENT_PATH/antora-playbook.yml" >&2
      exit 1
      ;;
    *)
      CURRENT_VERSION="$CURRENT_VERSION.x"
      echo "INFO: Detected version: $CURRENT_VERSION" >&2
      ;;
  esac
}

fetch_conf_files_content() {
  RAW_CONTENT=""
  # Fetching property files content
  for URL in https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/che.properties https://raw.githubusercontent.com/eclipse/che/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/multiuser.properties
  do
    if ! RAW_CONTENT="$RAW_CONTENT $(curl -sf "$URL")"
    then
      echo "ERROR: Cannot read multiuser.properties from URL $URL" >&2
      exit 1
    fi
    echo "INFO: Fetched content from $URL"
  done
}

parse_content() {
  while read -r LINE
  do
    # A line starting with two or more `#` is a topic title
    if [[ $LINE == '##'* ]]
    then 
      # Topic is the line, without any `#`
      TOPIC="${LINE//#}"
    # A line starting with single `#` belongs to a property description (can be multi-line)
    elif [[ $LINE == '#'* ]] && [[ -n $TOPIC ]]
    then   
      # Collect all description lines into buffer, stripping first #
      DESCR_BUFF="$DESCR_BUFF${LINE/\#}"
    # An empty line is a separator
    elif [[ -z $LINE ]] && [[ -n $TOPIC ]]
    then
      # Cleanup parameter name, description, and default value
      DESCR_BUFF=""
      KEY=""
      VALUE=""
    # A non-empty line after any topic that doesn't start with # is a parameter
    elif [[ -n $TOPIC ]]; then                          
      handle_parameter
    fi
  done <<< "$RAW_CONTENT"
}

handle_parameter() {
  # Split property line into key and value
  IFS=$'=' read -r KEY VALUE <<< "$LINE"
  # Replace single underscores with double
  ENV="${KEY//_/__}"
  # Replace dots with single underscore
  ENV="${ENV//./_}"
  # Determine output file name
  FILENAME="$OUTPUT_PATH/ref_che-server-parameter-${ENV}.adoc" 
  # If file doesn't exist or the -f option is invoked create draft
  if [[ ! -f "$FILENAME" ]] || [[ "$GENERATE_ALL" == "true" ]]
    then create_draft
  fi
  PARAMETER_LIST="$PARAMETER_LIST $ENV"
}

create_draft() {
  # Trim first space
  VALUE="${VALUE/ }"
  # Handle empty value
  VALUE="${VALUE:-Undefined}"
  # Trim first space
  DESCR_BUFF="${DESCR_BUFF/ }"
  # Escape { when it is a parameter name and not an attribute
  DESCR_BUFF="${DESCR_BUFF/\$\{/\$\\\{}"
  # Fix broken link
  DESCR_BUFF="$(sed -E 's|https://docs.openshift.com/container-platform/latest/architecture/additional_concepts/storage.html#pv-access-modes|https://docs.openshift.com/container-platform/4.4/storage/understanding-persistent-storage.html|' <<< $DESCR_BUFF)"
  # Fix broken link
  DESCR_BUFF="$(sed -E 's|https://docs.openshift.com/container-platform/latest/dev_guide/compute_resources.html#dev-compute-resources|https://docs.openshift.com/container-platform/4.4/storage/understanding-persistent-storage.html|' <<< $DESCR_BUFF)"
  # Fix broken link
  DESCR_BUFF="$(sed -E 's|https://www.keycloak.org/docs/3.3/server_admin/topics/identity-broker/social/openshift.html|https://www.keycloak.org/docs/latest/server_admin/index.html#openshift-4|' <<< $DESCR_BUFF)"

  # Create draft file
  eval "cat > "$FILENAME" <<EOF
  $(<$TOOLS_PATH/environment_docs_gen_template_ref_che-server-parameter.adoc)"
  echo "New draft: $FILENAME"
}


create_unordered_assembly() {
  ASSEMBLY="$OUTPUT_PATH/assembly_che-server-parameters-reference_raw.adoc"
  cat > "$ASSEMBLY" <"$TOOLS_PATH/environment_docs_gen_template_assembly_che-server-parameters-reference.adoc"
  for ENV in $PARAMETER_LIST
  do
  echo "include::ref_che-server-parameter-${ENV}.adoc[leveloffset=+1]" >> "$ASSEMBLY"
  done
}

# Using getopts to read the options - see http://tldp.org/LDP/abs/html/internal.html#EX33
while getopts ":hf" Option
do
  case "${Option}" in
    f) 
      GENERATE_ALL="true" 
      ;;
    h)
      usage
      ;;
    *) 
      GENERATE_ALL="false" 
      ;;
  esac
done

run

# Decrements the argument pointer so it points to next argument.
shift $((OPTIND - 1))
