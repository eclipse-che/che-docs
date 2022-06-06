#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
PRODUCT_SHORT_ID=${PRODUCT_SHORT_ID:-che}                                        # {prod-id-short}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
PRODUCT_DEPLOYMENT_NAME=${PRODUCT_DEPLOYMENT_NAME:-che}                          # {prod-deployment}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-opпerators}                    # {?}

PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE=${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE:-eclipse-che}         # {prod-namespace}
PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME=${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME:-che}                       # {pre-migration-prod-deployment}
PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME=${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME:-eclipse-che}           # {pre-migration-prod-subscription}
PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME=${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME:-eclipse-che}       # {pre-migration-prod-checluster}
PRE_MIGRATION_PRODUCT_OPERATOR_NAME=${PRE_MIGRATION_PRODUCT_OPERATOR_NAME:-che-operator}                  # {pre-migration-prod-operator}
PRE_MIGRATION_PRODUCT_OLM_PACKAGE=${PRE_MIGRATION_PRODUCT_OLM_PACKAGE:-eclipse-che}                       # {pre-migration-prod-package}
PRE_MIGRATION_PRODUCT_OLM_CHANNEL=${PRE_MIGRATION_PRODUCT_OLM_CHANNEL:-stable}                            # {pre-migration-prod-channel}
PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE=${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE:-community-operators} # {pre-migration-prod-catalog-source}

DB_DUMP="${PRODUCT_ID}"-original-db.sql

echo "[INFO] Retriving ${PRODUCT_ID} database name."
CHE_POSTGRES_DB=$("${K8S_CLI}" get cm/che -n "${INSTALLATION_NAMESPACE}" -o jsonpath='{.data.CHE_JDBC_URL}' | awk -F '/' '{print $NF}')

deleteOperatorCSV() {
    if "${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting operator cluster service version."
        "${K8S_CLI}" delete csv "$("${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" -o jsonpath="{.status.currentCSV}")" -n "${OPERATOR_NAMESPACE}"
    else
        echo "[INFO] Skipping CSV deletion. No ${PRODUCT_ID} operator subscription found."
    fi
}

deleteOperatorSubscription() {
    if "${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
        echo "[INFO] Deleting ${PRODUCT_ID} operator subscription."
        "${K8S_CLI}" delete subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}"

        echo "[INFO] Waiting 30s for the old ${PRODUCT_ID} operator deletion."
        sleep 30
    else
        echo "[INFO] Skipping subscription deletion as no ${PRODUCT_ID} operator subscription was found."
    fi
}

patchCheCluster() {
    echo "[INFO] Updating ${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to switch to turn off DevWorkspace engine."
    "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
        '[{"op": "replace", "path": "/spec/devWorkspace/enable", "value": false}]'
}

terminatePostgresConnections() {
  echo "[INFO] Terminating ${PRODUCT_ID} database connections."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${CHE_POSTGRES_DB}'\""
}

dropExistingDatabase() {
  echo "[INFO] Dropping ${PRODUCT_ID} database."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "dropdb ${CHE_POSTGRES_DB}"
}

createDatabase() {
  echo "[INFO] Creating a new ${PRODUCT_ID} database."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql postgres -tAc \"CREATE DATABASE ${CHE_POSTGRES_DB}\""
}

restoreDatabase() {
  echo "[INFO] Uploading ${DB_DUMP} to the postgreSQL pod."
  "${K8S_CLI}" cp "${DB_DUMP}" "${INSTALLATION_NAMESPACE}"/"$("${K8S_CLI}" get pods -l app.kubernetes.io/component=postgres -n "${INSTALLATION_NAMESPACE}" --no-headers=true  -o custom-columns=":metadata.name")":/tmp/che.sql

  echo "[INFO] Populating ${DB_DUMP} database with the new content."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} < /tmp/che.sql"
}

deleteObjects() {
    echo "[INFO] Deleting obsolete resources."
    echo "[INFO] Deleting deployments."
    for DEPLOYMENT in "${PRODUCT_DEPLOYMENT_NAME}" "${PRODUCT_SHORT_ID}-dashboard" "plugin-registry" "devfile-registry" "che-gateway" "postgres"; do
        "${K8S_CLI}" delete deployment "${DEPLOYMENT}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] deployment ${DEPLOYMENT} not found."
    done  

    echo "[INFO] Deleting routes."
    "${K8S_CLI}" delete route "${PRODUCT_SHORT_ID}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Route ${PRODUCT_SHORT_ID} not found."

    echo "[INFO] Deleting services."
    for SERVICE in "che-host" "${PRODUCT_SHORT_ID}-dashboard" "plugin-registry" "devfile-registry" "che-gateway" "postgres"; do
        "${K8S_CLI}" delete service "${SERVICE}" -n "${INSTALLATION_NAMESPACE}" > /dev/null 2>&1 || echo "[INFO] Service ${SERVICE} not found."
    done
}

createOperatorSubscription() {
    echo "[INFO] Creating new ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription." 
    echo "[INFO] New subscription source: ${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE}."
    echo "[INFO] New subscription channel: ${PRE_MIGRATION_PRODUCT_OLM_CHANNEL}."
    echo "[INFO] New subscription name: ${PRE_MIGRATION_PRODUCT_OLM_PACKAGE}."

    "${K8S_CLI}" apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}"
    namespace: "${INSTALLATION_NAMESPACE}"
spec:
    channel: "${PRE_MIGRATION_PRODUCT_OLM_CHANNEL}"
    installPlanApproval: Automatic
    name: "${PRE_MIGRATION_PRODUCT_OLM_PACKAGE}"
    source: "${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE}"
    sourceNamespace: openshift-marketplace
EOF
}

waitForComponent() {
  component=$1
  namespace=$2
  echo "[INFO] Waiting for ${component} Pod to be created"
  while [[ $("${K8S_CLI}" get pod -l app.kubernetes.io/component="${component}" -n "${namespace}" -o go-template='{{len .items}}') == 0 ]]
  do
    echo "[INFO] Waiting..."
    sleep 10
  done
  echo "[INFO] Waiting for ${component} Pod to be ready"
  "${K8S_CLI}" wait --for=condition=ready pod -l app.kubernetes.io/component="${component}" -n "${namespace}" --timeout=120s
}


deleteOperatorCSV
deleteOperatorSubscription
patchCheCluster

terminatePostgresConnections
dropExistingDatabase
createDatabase
restoreDatabase

deleteObjects
createOperatorSubscription

waitForComponent "${PRE_MIGRATION_PRODUCT_OPERATOR_NAME}" "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}"
waitForComponent "${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}" "${INSTALLATION_NAMESPACE}"

echo "[INFO] Done."
