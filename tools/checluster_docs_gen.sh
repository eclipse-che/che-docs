#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -o pipefail
set -e
umask 002
info() {
  echo -e "\e[32mINFO $1"
}
error() {
  echo -e "\e[31mERROR $1"
}

CURRENT_VERSION=""
PRODUCT=""
RAW_CONTENT=""
NEWLINE=$'\n'
NEWLINEx2="$NEWLINE$NEWLINE"
TABLE_HEADER="$NEWLINE[cols=\"2,5\", options=\"header\"]$NEWLINE:=== $NEWLINE Property: Description $NEWLINE"
TABLE_FOOTER=":=== $NEWLINEx2"
PARENT_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  pwd -P
)
BUFF=""
OUTPUT_DIR="$PARENT_PATH/build/collector/checluster-properties"
OUTPUT_PATH="$OUTPUT_DIR/checluster-properties.adoc"

mkdir -p "$OUTPUT_DIR"

fetch_current_version() {
  # info "Trying to read current product version from $PARENT_PATH/antora.yml..." >&2
  # remove spaces, single and double quotes from the value of prod-ver, then append x.
  CURRENT_VERSION=$(yq -M '.asciidoc.attributes."prod-ver"' "$PARENT_PATH/antora.yml" | tr -d " '\"").x
  if [[ "$CURRENT_VERSION" == 'main.x' ]]; then
    CURRENT_VERSION="main"
  fi

  info "Version: $CURRENT_VERSION" >&2
}

fetch_product_name() {
  # info "Trying to read product name from $PARENT_PATH/antora.yml..." >&2
  PRODUCT=$(yq -rM '.asciidoc.attributes."prod-id-short"' "$PARENT_PATH/antora.yml")
  info "Product: $PRODUCT" >&2
}

fetch_conf_files_content() {
  # info "Fetching property files content from GitHub..." >&2

  if [[ $PRODUCT == "che" ]]; then
    CHECLUSTER_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse-che/che-operator/$CURRENT_VERSION/config/crd/bases/org.eclipse.che_checlusters.yaml"
  else
    CHECLUSTER_PROPERTIES_URL="https://raw.githubusercontent.com/redhat-developer/codeready-workspaces-operator/$CURRENT_VERSION/config/crd/bases/org.eclipse.che_checlusters.yaml"
  fi

  RAW_CONTENT=$(curl -sf "$CHECLUSTER_PROPERTIES_URL")
  #  info "Fetching content done. Trying to parse it." >&2
}

parse_content() {
  parse_section "devEnvironments" "Development environment configuration options."
  parse_section "devEnvironments.properties.defaultNamespace" "Development environment \`defaultNamespace\` options."
  parse_section "devEnvironments.properties.storage" "Development environment \`storage\` options."
  parse_section "components" "{prod-short} components configuration."
  parse_section "components.properties.devWorkspace" "DevWorkspace operator component configuration."
  parse_section "components.properties.cheServer" "General configuration settings related to the {prod-short} server component."
  parse_section "components.properties.pluginRegistry" "Configuration settings related to the Plug-in registry component used by the {prod-short} installation."
  parse_section "components.properties.devfileRegistry" "Configuration settings related to the Devfile registry component used by the {prod-short} installation."
  parse_section "components.properties.database" "Configuration settings related to the Database component used by the {prod-short} installation."
  parse_section "components.properties.dashboard" "Configuration settings related to the Dashboard component used by the {prod-short} installation."
  parse_section "components.properties.imagePuller" "Kubernetes Image Puller component configuration."
  parse_section "components.properties.metrics" "{prod-short} server metrics component configuration."
  parse_section "networking" "Networking, {prod-short} authentication and TLS configuration."
  parse_section "containerRegistry" "Configuration of an alternative registry that stores {prod-short} images."
  parse_section "status" "\`CheCluster\` Custom Resource \`status\` defines the observed state of {prod-short} installation"
  echo "$BUFF" >"$OUTPUT_PATH"
  info "Single-sourced $OUTPUT_PATH" >&2
}

parse_section() {
  local section
  local sectionName=$1
  local sectionName2Id=$(echo $sectionName | tr '.' '-')
  local id="[id=\"checluster-custom-resource-$sectionName2Id-settings\"]"
  local caption=$2

  # info "Parsing section: "$sectionName
  if [[ $sectionName == "status" ]]; then
    section=$(echo "$RAW_CONTENT" | yq -M '.spec.versions[] | select(.name == "v2") | .schema.openAPIV3Schema.properties.status')
  else
    section=$(echo "$RAW_CONTENT" | yq -M '.spec.versions[] | select(.name == "v2") | .schema.openAPIV3Schema.properties.spec.properties.'"$sectionName")
  fi

  local properties=(
    $(echo "$section" | yq -M '.properties | keys[]')
  )

  BUFF="$BUFF$id$NEWLINE"
  BUFF="$BUFF.$caption$NEWLINE"
  BUFF="$BUFF$TABLE_HEADER"
  for PROP in "${properties[@]}"; do
    PROP="${PROP//\"/}"
    DESCR_BUFF=$(echo "$section" | yq -M '.properties.'"$PROP"'.description')
    DESCR_BUFF="${DESCR_BUFF//\"/}"
    DESCR_BUFF="${DESCR_BUFF//:/\\:}"
    DESCR_BUFF="$(sed 's|Eclipse Che|{prod-short}|g' <<<$DESCR_BUFF)"
    BUFF="$BUFF${PROP}: ${DESCR_BUFF}$NEWLINE"
  done
  BUFF="$BUFF$TABLE_FOOTER"
}

fetch_current_version
fetch_product_name
fetch_conf_files_content
parse_content
