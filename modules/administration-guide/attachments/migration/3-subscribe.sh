#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
PRODUCT_OLM_STABLE_CHANNEL=${PRODUCT_OLM_STABLE_CHANNEL:-stable}                                 # {prod-stable-channel}
PRODUCT_OLM_CATALOG_SOURCE=${PRODUCT_OLM_CATALOG_SOURCE:-community-operators}                    # {prod-stable-channel-catalog-source}
PRODUCT_OLM_PACKAGE=${PRODUCT_OLM_PACKAGE:-eclipse-che}                                          # {prod-stable-channel-package}

MIGRATION_PRODUCT_SHORT_ID=${MIGRATION_PRODUCT_SHORT_ID:-che}                                    # {prod-migration-short-id}
MIGRATION_PRODUCT_SUBSCRIPTION_NAME=${MIGRATION_PRODUCT_SUBSCRIPTION_NAME:-eclipse-che}          # {prod-migration-subscription}
MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME=${MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME:-eclipse-che}      # {prod-migration-checluster}
MIGRATION_PRODUCT_OPERATOR_NAME=${MIGRATION_PRODUCT_OPERATOR_NAME:-che-operator}                 # {prod-migration-operator}
MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME=${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME:-keycloak} # {identity-provider-id}

deleteOperatorCSV() {
    if "${K8S_CLI}" get subscription "${MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting operator cluster service version."
        "${K8S_CLI}" delete csv "$("${K8S_CLI}" get subscription "${MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.status.currentCSV}")" -n "${INSTALLATION_NAMESPACE}"
    else
        echo "[INFO] Skipping CSV deletion. No ${MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription found."
    fi
}

deleteOperatorSubscription() {
    if "${K8S_CLI}" get subscription "${MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting ${MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription."
        "${K8S_CLI}" delete subscription "${MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${INSTALLATION_NAMESPACE}"
    else
        echo "[INFO] Skipping subscription deletion as no ${MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription was found."
        echo "[INFO] Deleting the ${PRODUCT_ID} operator deployment instead."
        "${K8S_CLI}" delete deployment "${MIGRATION_PRODUCT_OPERATOR_NAME}" -n "${INSTALLATION_NAMESPACE}"
    fi
    echo "[INFO] Waiting 30s for the old ${PRODUCT_ID} operator deletion."
    sleep 30
}

patchCheCluster() {
    echo "[INFO] Updating ${MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to switch to DevWorkspace and single-host."
    "${K8S_CLI}" patch checluster/"${MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/devWorkspace/enable", "value": true}]'
    "${K8S_CLI}" patch checluster/"${MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/server/serverExposureStrategy", "value": "single-host"}]'
}

cleanupObsoleteObjects() {
    echo "[INFO] Deleting obsolete resources."
    "${K8S_CLI}" delete route "${MIGRATION_PRODUCT_SHORT_ID}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${MIGRATION_PRODUCT_SHORT_ID} not found."
    "${K8S_CLI}" delete route "${MIGRATION_PRODUCT_SHORT_ID}-dashboard" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${MIGRATION_PRODUCT_SHORT_ID}-dashboard not found."
    "${K8S_CLI}" delete route "${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
    "${K8S_CLI}" delete service "${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Service ${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
    "${K8S_CLI}" delete deployment "${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Deployment ${MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
}

createOperatorSubscription() {
    echo "[INFO] Creating new ${PRODUCT_ID} operator subscription." 
    echo "[INFO] New subscription source: ${PRODUCT_OLM_CATALOG_SOURCE}."
    echo "[INFO] New subscription channel: ${PRODUCT_OLM_STABLE_CHANNEL}."
    echo "[INFO] New subscription name: ${PRODUCT_OLM_PACKAGE}."

    "${K8S_CLI}" apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: "${PRODUCT_ID}"
    namespace: openshift-operators
spec:
    channel: "${PRODUCT_OLM_STABLE_CHANNEL}"
    installPlanApproval: Automatic
    name: "${PRODUCT_OLM_PACKAGE}"
    source: "${PRODUCT_OLM_CATALOG_SOURCE}"
    sourceNamespace: openshift-marketplace
EOF

}

deleteOperatorCSV
deleteOperatorSubscription
patchCheCluster
cleanupObsoleteObjects
createOperatorSubscription

echo "[INFO] Done."
