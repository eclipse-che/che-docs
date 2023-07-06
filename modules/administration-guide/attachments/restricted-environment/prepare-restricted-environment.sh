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
# set -x

# Operators
declare devworkspace_operator_index="${devworkspace_operator_index:?Define the variable}"
declare devworkspace_operator_package_name="devworkspace-operator"
declare devworkspace_operator_version="${devworkspace_operator_version:?Define the variable}"
declare prod_operator_index="${prod_operator_index:?Define the variable}"
declare prod_operator_package_name="${prod_operator_package_name:?Define the variable}"
declare prod_operator_version="${prod_operator_version:?Define the variable}"

# Destination registry
declare my_registry="${my_registry:?Define the variable}"
declare my_catalog=restricted-environment-install
declare my_operator_index="$my_registry/$my_catalog/my-operator-index:latest"

# Create local directories
mkdir -p "${my_catalog}/${devworkspace_operator_package_name}" "${my_catalog}/${prod_operator_package_name}"

echo "Fetching metadata for the ${devworkspace_operator_package_name} operator catalog channel, packages, and bundles."
opm render "${devworkspace_operator_index}" \
  | jq "select \
    (\
      (.schema == \"olm.bundle\" and .name == \"${devworkspace_operator_package_name}.${devworkspace_operator_version}\") or \
      (.schema == \"olm.package\" and .name == \"${devworkspace_operator_package_name}\") or \
      (.schema == \"olm.channel\" and .package == \"${devworkspace_operator_package_name}\") \
    )" \
  | jq "select \
     (.schema == \"olm.channel\" and .package == \"${devworkspace_operator_package_name}\").entries \
      |= [{name: \"${devworkspace_operator_package_name}.${devworkspace_operator_version}\"}]" \
  > "${my_catalog}/${devworkspace_operator_package_name}/render.json"

echo "Fetching metadata for the ${prod_operator_package_name} operator catalog channel, packages, and bundles."
opm render "${prod_operator_index}" \
  | jq "select \
    (\
      (.schema == \"olm.bundle\" and .name == \"${prod_operator_package_name}.${prod_operator_version}\") or \
      (.schema == \"olm.package\" and .name == \"${prod_operator_package_name}\") or \
      (.schema == \"olm.channel\" and .package == \"${prod_operator_package_name}\") \
    )" \
  | jq "select \
     (.schema == \"olm.channel\" and .package == \"${prod_operator_package_name}\").entries \
      |= [{name: \"${prod_operator_package_name}.${prod_operator_version}\"}]" \
  > "${my_catalog}/${prod_operator_package_name}/render.json"

echo "Creating the catalog dockerfile."
if [ -f "${my_catalog}.Dockerfile" ]; then
  rm -f "${my_catalog}.Dockerfile"
fi
opm alpha generate dockerfile "./${my_catalog}"

echo "Building the catalog image locally."
podman build -t "${my_operator_index}" -f "./${my_catalog}.Dockerfile" --no-cache .

echo "Disabling the default Red Hat Ecosystem Catalog."
oc patch OperatorHub cluster --type json \
    --patch '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

echo "Deploying your catalog image to the $my_operator_index registry."
# See: https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-installation-images.html#olm-mirroring-catalog_installing-mirroring-installation-images
skopeo copy --dest-tls-verify=false --all "containers-storage:$my_operator_index" "docker://$my_operator_index"

echo "Creating the 'che-operator-cr-patch.yaml' file locally."
cat > che-operator-cr-patch.yaml << EOF
kind: CheCluster
apiVersion: org.eclipse.che/v2
spec:
  components:
    pluginRegistry:
      openVSXURL: ""
EOF

echo "Removing index image from mappings.txt to prepare mirroring."
oc adm catalog mirror "$my_operator_index" "$my_registry" --insecure --manifests-only | tee catalog_mirror.log
MANIFESTS_FOLDER=$(sed -n -e 's/^wrote mirroring manifests to \(.*\)$/\1/p' catalog_mirror.log |xargs) # The xargs here is to trim whitespaces
sed -i -e "/my-operator-index:latest/d" "${MANIFESTS_FOLDER}/mapping.txt"
cat "${MANIFESTS_FOLDER}/mapping.txt"

echo "Mirroring related images to the $my_registry registry."
oc image mirror --insecure=true -f "${MANIFESTS_FOLDER}/mapping.txt"

# Use skopeo for non Red Hat registries to preserve the original digest
while IFS= read -r line
do
  images=(
    $(echo $line | tr "=" "\n")
  )

  public_image=${images[1]}
  private_image=${images[2]}

  if [[ ! $public_image =~ ^quay.io ]] && [[ ! $public_image =~ ^registry.redhat.io ]]; then
    echo "Preserving digest for $public_image"
    skopeo copy --preserve-digests --all "docker://$public_image" "docker://$private_image"
  fi
done < "${MANIFESTS_FOLDER}/mapping.txt"

echo "Creating CatalogSource and ImageContentSourcePolicy"
cat ${MANIFESTS_FOLDER}/catalogSource.yaml | oc apply -f -
cat ${MANIFESTS_FOLDER}/imageContentSourcePolicy.yaml | oc apply -f -

echo "INFO: Catalog $my_operator_index deployed to the $my_registry registry."