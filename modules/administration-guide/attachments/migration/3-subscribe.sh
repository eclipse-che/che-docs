#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-kubectl}                                                      # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
CHE_CLUSTER_CR_NAME=${CHE_CLUSTER_CR_NAME:-eclipse-che}                          # {prod-checluster}

OLM_STABLE_CHANNEL=${OLM_STABLE_CHANNEL:-stable}                                 # {prod-stable-channel}
OLM_CATALOG_SOURCE=${OLM_CATALOG_SOURCE:-community-operators}                    # {prod-stable-channel-catalog-source}
OLM_PACKAGE=${OLM_PACKAGE:-eclipse-che}                                          # {prod-stable-channel-package}

IDENTITY_PROVIDER_DEPLOYMENT_NAME=${IDENTITY_PROVIDER_DEPLOYMENT_NAME:-keycloak} # {?}

deleteOperatorCSV() {
    echo "[INFO] Deleting operator cluster service version."
    "${K8S_CLI}" delete csv "$("${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.status.currentCSV}")" -n "${INSTALLATION_NAMESPACE}"
}

deleteOperatorSubscription() {
    echo "[INFO] Deleting ${PRODUCT_ID} operator subscription."
    "${K8S_CLI}" delete subscription "${PRODUCT_ID}" -n "${INSTALLATION_NAMESPACE}"
}

patchCheCluster() {
    echo "[INFO] Updating ${CHE_CLUSTER_CR_NAME} CheCluster CR to switch to DevWorkspace and single-host."
    "${K8S_CLI}" patch checluster/"${CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/devWorkspace/enable", "value": true}]'
    "${K8S_CLI}" patch checluster/"${CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/server/serverExposureStrategy", "value": "single-host"}]'
}

cleanupIdentityProviderObjects() {
    echo "[INFO] Deleting ${IDENTITY_PROVIDER_DEPLOYMENT_NAME} resources."
    "${K8S_CLI}" delete route "${IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}"
    "${K8S_CLI}" delete service "${IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}"
    "${K8S_CLI}" delete deployment "${IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}"
}

createOperatorSubscription() {
    echo "[INFO] Creating new ${PRODUCT_ID} operator subscription." 
    echo "[INFO] New subscription source: ${OLM_CATALOG_SOURCE}."
    echo "[INFO] New subscription channel: ${OLM_STABLE_CHANNEL}."
    echo "[INFO] New subscription name: ${OLM_PACKAGE}."

    "${K8S_CLI}" apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
name: "${PRODUCT_ID}"
namespace: openshift-operators
spec:
channel: "${OLM_STABLE_CHANNEL}"
installPlanApproval: Automatic
name: "${OLM_PACKAGE}"
source: "${OLM_CATALOG_SOURCE}"
sourceNamespace: openshift-marketplace
EOF

}

deleteOperatorCSV
deleteOperatorSubscription
patchCheCluster
cleanupIdentityProviderObjects
createOperatorSubscription

echo "[INFO] Done."
