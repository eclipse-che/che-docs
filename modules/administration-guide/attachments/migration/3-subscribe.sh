#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-eclipse-che}                        # {prod-namespace}
PRODUCT_OLM_STABLE_CHANNEL=${PRODUCT_OLM_STABLE_CHANNEL:-stable}                                 # {prod-stable-channel}
PRODUCT_OLM_CATALOG_SOURCE=${PRODUCT_OLM_CATALOG_SOURCE:-community-operators}                    # {prod-stable-channel-catalog-source}
PRODUCT_OLM_PACKAGE=${PRODUCT_OLM_PACKAGE:-eclipse-che}                                          # {prod-stable-channel-package}

PRE_MIGRATION_PRODUCT_SHORT_ID=${PRE_MIGRATION_PRODUCT_SHORT_ID:-che}                                    # {pre-migration-prod-id-short}
PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME=${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME:-eclipse-che}          # {pre-migration-prod-subscription}
PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME=${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME:-eclipse-che}      # {pre-migration-prod-checluster}
PRE_MIGRATION_PRODUCT_OPERATOR_NAME=${PRE_MIGRATION_PRODUCT_OPERATOR_NAME:-che-operator}                 # {pre-migration-prod-operator}
PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME=${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME:-keycloak} # {identity-provider-id}

deleteOperatorCSV() {
    if "${K8S_CLI}" get subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting operator cluster service version."
        "${K8S_CLI}" delete csv "$("${K8S_CLI}" get subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${OPERATOR_NAMESPACE}" -o jsonpath="{.status.currentCSV}")" -n "${OPERATOR_NAMESPACE}"
    else
        echo "[INFO] Skipping CSV deletion. No ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription found."
    fi
}

deleteOperatorSubscription() {
    if "${K8S_CLI}" get subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription."
        "${K8S_CLI}" delete subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${OPERATOR_NAMESPACE}"
    else
        echo "[INFO] Skipping subscription deletion as no ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription was found."
        echo "[INFO] Deleting the ${PRODUCT_ID} operator deployment instead."
        "${K8S_CLI}" delete deployment "${PRE_MIGRATION_PRODUCT_OPERATOR_NAME}" -n "${OPERATOR_NAMESPACE}"
    fi
    echo "[INFO] Waiting 30s for the old ${PRODUCT_ID} operator deletion."
    sleep 30
}

patchCheCluster() {
    echo "[INFO] Updating ${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to switch to DevWorkspace and single-host."
    "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/devWorkspace/enable", "value": true}]'
    "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/server/serverExposureStrategy", "value": "single-host"}]'

    echo "[INFO] Updating ${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to clean up default ${PRODUCT_ID} host"
    CHE_HOST=$("${K8S_CLI}" get checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath='{.spec.server.cheHost}')
    if [[ "${CHE_HOST}" =~ ${PRE_MIGRATION_PRODUCT_SHORT_ID}-${INSTALLATION_NAMESPACE} ]]; then
      "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
              '[{"op": "replace", "path": "/spec/server/cheHost", "value": ""}]'
    fi
}

cleanupObsoleteObjects() {
    echo "[INFO] Deleting obsolete resources."
    "${K8S_CLI}" delete route "${PRE_MIGRATION_PRODUCT_SHORT_ID}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${PRE_MIGRATION_PRODUCT_SHORT_ID} not found."
    "${K8S_CLI}" delete deployment "${PRE_MIGRATION_PRODUCT_SHORT_ID}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] deployment ${PRE_MIGRATION_PRODUCT_SHORT_ID} not found."

    "${K8S_CLI}" delete configmap "che-gateway-route-${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] ConfigMap che-gateway-route-${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard not found."
    "${K8S_CLI}" delete service "${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Service ${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard not found."
    "${K8S_CLI}" delete route "${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard not found."
    "${K8S_CLI}" delete deployment "${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Deployment ${PRE_MIGRATION_PRODUCT_SHORT_ID}-dashboard not found."

    "${K8S_CLI}" delete route "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
    "${K8S_CLI}" delete service "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Service ${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
    "${K8S_CLI}" delete deployment "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Deployment ${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME} not found."
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
