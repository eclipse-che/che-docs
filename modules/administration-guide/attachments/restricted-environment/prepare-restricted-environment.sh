#!/bin/bash
#
# Copyright (c) 2022 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fail on error
set -e

# Handle command line parameters
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare "$param"="$2"
  fi
  shift
done

# Display commands
set -x

# OpenShift cluster version
declare ocp_ver="${ocp_ver:?Define the variable}"

# Operators
declare devworkspace_operator_index="${devworkspace_operator_index:?Define the variable}"
declare devworkspace_operator_package_name="devworkspace-operator"
declare devworkspace_operator_version="${devworkspace_operator_version:?Define the variable}"
declare prod_operator_index="${prod_operator_index:?Define the variable}"
declare prod_operator_package_name="${prod_operator_package_name:?Define the variable}"
declare prod_operator_version="${prod_operator_version:?Define the variable}"

# Destination registry
declare my_registry="${my_registry:-default-route-openshift-image-registry.apps-crc.testing}"
declare my_catalog="${my_catalog:-restricted-environment-install}"
declare my_operator_index="$my_registry/$my_catalog/my-operator-index:v${ocp_ver}"

# Create local directories
mkdir -p "${my_catalog}/${devworkspace_operator_package_name}" "${my_catalog}/${prod_operator_package_name}"

# Get metadata for the operator catalog channels and packages.
# Filter only the operator channel and the required version bundle
# to limit the number of related images to mirror.
opm render "${devworkspace_operator_index}" \
  | jq "select(\
    .name == \"${devworkspace_operator_package_name}\" \
    or (.package == \"${devworkspace_operator_package_name}\" and .schema == \"olm.channel\" ) \
    or .name == \"${devworkspace_operator_package_name}.${devworkspace_operator_version}\" \
    )" \
  > "${my_catalog}/${devworkspace_operator_package_name}/render.json"

opm render "${prod_operator_index}" \
  | jq "select(\
    .name == \"${prod_operator_package_name}\" \
    or (.package == \"${prod_operator_package_name}\" and .schema == \"olm.channel\" ) \
    or .name == \"${prod_operator_package_name}.${prod_operator_version}\" \
    )" \
  > "${my_catalog}/${prod_operator_package_name}/render.json"

# Create the catalog dockerfile
if [ -f "${my_catalog}.Dockerfile" ]; then
  rm -f "${my_catalog}.Dockerfile"
fi
opm alpha generate dockerfile "./${my_catalog}"

# Build the catalog image locally
podman build -t "${my_operator_index}" -f "./${my_catalog}.Dockerfile" --no-cache .

# Disable default Red Hat Ecosystem Catalog
oc patch OperatorHub cluster --type json \
    --patch '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# Deploy my catalog image
oc delete project "$my_catalog" --grace-period=1 --ignore-not-found=true
oc wait --for=delete "project/$my_catalog"
sleep 5
oc new-project "$my_catalog"
skopeo copy --dest-tls-verify=false --all "containers-storage:$my_operator_index" "docker://$my_operator_index"

# Deploy my catalog source
oc apply -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: $my_catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: $my_operator_index
EOF

# Create CheCluster custom resource configuration file
cat > che-operator-cr-patch.yaml << EOF
kind: CheCluster
apiVersion: org.eclipse.che/v1
spec:
  server:
    airGapContainerRegistryHostname: "$my_registry"
    airGapContainerRegistryOrganization: "${my_catalog}"
EOF

# Mirror related images
oc adm catalog mirror "$my_operator_index" "$my_registry" --insecure

echo "INFO: Catalog $my_operator_index deployed to the $my_registry registry."
