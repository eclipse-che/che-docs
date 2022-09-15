#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
PRODUCT_SHORT_ID=${PRODUCT_SHORT_ID:-che}                                        # {prod-id-short}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
PRODUCT_DEPLOYMENT_NAME=${PRODUCT_DEPLOYMENT_NAME:-che}                          # {prod-deployment}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}                    # {?}

PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE=${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE:-eclipse-che}         # {prod-namespace}
PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME=${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME:-che}                       # {pre-migration-prod-deployment}
PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME=${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME:-eclipse-che}           # {pre-migration-prod-subscription}
PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME=${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME:-eclipse-che}       # {pre-migration-prod-checluster}
PRE_MIGRATION_PRODUCT_OPERATOR_NAME=${PRE_MIGRATION_PRODUCT_OPERATOR_NAME:-che-operator}                  # {pre-migration-prod-operator}
PRE_MIGRATION_PRODUCT_OLM_PACKAGE=${PRE_MIGRATION_PRODUCT_OLM_PACKAGE:-eclipse-che}                       # {pre-migration-prod-package}
PRE_MIGRATION_PRODUCT_OLM_CHANNEL=${PRE_MIGRATION_PRODUCT_OLM_CHANNEL:-stable}                            # {pre-migration-prod-channel}
PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE=${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE:-community-operators} # {pre-migration-prod-catalog-source}
PRE_MIGRATION_PRODUCT_OLM_STARTING_CSV=${PRE_MIGRATION_PRODUCT_OLM_STARTING_CSV:-eclipse-che.v7.41.2}     # {pre-migration-prod-starting-csv}

ORIGINAL_DB_DUMP="${PRODUCT_ID}"-original-db.sql
ORIGINAL_CHE_CLUSTER_DUMP="${PRODUCT_ID}"-original-checluster.json

echo "[INFO] Retrieving ${PRODUCT_ID} database name."
CHE_POSTGRES_DB=$("${K8S_CLI}" get cm/che -n "${INSTALLATION_NAMESPACE}" -o jsonpath='{.data.CHE_JDBC_URL}' | awk -F '/' '{print $NF}')

deleteProductOperatorCSVIfExists() {
  if "${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
    echo "[INFO] Deleting operator cluster service version."
    "${K8S_CLI}" delete csv "$("${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" -o jsonpath="{.status.installedCSV}")" -n "${OPERATOR_NAMESPACE}"
  else
    echo "[INFO] Skipping CSV deletion. No ${PRODUCT_ID} operator subscription found."
  fi
}

deleteProductOperatorSubscriptionIfExists() {
  if "${K8S_CLI}" get subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
    echo "[INFO] Deleting ${PRODUCT_ID} operator subscription."
    "${K8S_CLI}" delete subscription "${PRODUCT_ID}" -n "${OPERATOR_NAMESPACE}"

    echo "[INFO] Waiting 30s for the old ${PRODUCT_ID} operator deletion."
    sleep 30
  else
    echo "[INFO] Skipping subscription deletion as no ${PRODUCT_ID} operator subscription was found."
  fi
}

restoreCheCluster() {
  echo "[INFO] Updating ${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to set DevWorkspace engine mode."
  DEV_WORKSPACE_ENABLE=$(cat "${ORIGINAL_CHE_CLUSTER_DUMP}" | jq -r '.spec.devWorkspace.enable')
  "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
      '[{"op": "replace", "path": "/spec/devWorkspace/enable", "value": '${DEV_WORKSPACE_ENABLE}'}]'

  echo "[INFO] Updating ${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME} CheCluster CR to set server exposure strategy."
  SEVER_EXPOSURE_STRATEGY=$(cat "${ORIGINAL_CHE_CLUSTER_DUMP}" | jq -r '.spec.server.serverExposureStrategy')
  "${K8S_CLI}" patch checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" --type=json -p \
    '[{"op": "replace", "path": "/spec/server/serverExposureStrategy", "value": "'${SEVER_EXPOSURE_STRATEGY}'"}]'
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
  echo "[INFO] Uploading ${ORIGINAL_DB_DUMP} to the PostgreSQL pod."
  "${K8S_CLI}" cp "${ORIGINAL_DB_DUMP}" "${INSTALLATION_NAMESPACE}"/"$("${K8S_CLI}" get pods -l app.kubernetes.io/component=postgres -n "${INSTALLATION_NAMESPACE}" --no-headers=true  -o custom-columns=":metadata.name")":/tmp/che.sql

  echo "[INFO] Populating ${ORIGINAL_DB_DUMP} database with the new content."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} < /tmp/che.sql"
}

deleteProductResourcesIfExist() {
  echo "[INFO] Deleting resources."

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

  echo "[INFO] Deleting console link."
  "${K8S_CLI}" delete consolelink che > /dev/null 2>&1 || echo "[INFO] ConsoleLink che not found."
}

createPreMigrationProductOperatorSubscription() {
  echo "[INFO] Creating new ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator subscription."
  echo "[INFO] New subscription name: ${PRE_MIGRATION_PRODUCT_OLM_PACKAGE}."
  echo "[INFO] New subscription channel: ${PRE_MIGRATION_PRODUCT_OLM_CHANNEL}."
  echo "[INFO] New subscription source: ${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE}."
  echo "[INFO] New subscription starting CSV: ${PRE_MIGRATION_PRODUCT_OLM_STARTING_CSV}."

  "${K8S_CLI}" apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}"
    namespace: "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}"
spec:
    channel: "${PRE_MIGRATION_PRODUCT_OLM_CHANNEL}"
    installPlanApproval: Manual
    name: "${PRE_MIGRATION_PRODUCT_OLM_PACKAGE}"
    source: "${PRE_MIGRATION_PRODUCT_OLM_CATALOG_SOURCE}"
    sourceNamespace: openshift-marketplace
    startingCSV: ${PRE_MIGRATION_PRODUCT_OLM_STARTING_CSV}
EOF

  echo "[INFO] Waiting 30s for the new ${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME} operator creation."
  sleep 30
  "${K8S_CLI}" wait subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}" --for=condition=InstallPlanPending --timeout=120s

  echo "[INFO] Approve install plan."
  INSTALL_PLAN=$("${K8S_CLI}" get subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}" -o jsonpath='{.status.installplan.name}')
  "${K8S_CLI}" patch installplan ${INSTALL_PLAN} -n "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}" --type=merge -p '{"spec": {"approved": true}}'
}

scaleUpCheServer() {
  echo "[INFO] Scaling up ${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}"
  "${K8S_CLI}" scale deployment "${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}" --replicas=1 -n "${INSTALLATION_NAMESPACE}"
}

scaleUpKeycloak() {
  echo "[INFO] Scaling up ${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}"
  "${K8S_CLI}" scale deployment "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" --replicas=1 -n "${INSTALLATION_NAMESPACE}"
}

waitForComponent() {
  component=$1
  namespace=$2
  echo "[INFO] Waiting for ${component} Pod to be created."
  while [[ $("${K8S_CLI}" get pod -l app.kubernetes.io/component="${component}" -n "${namespace}" -o go-template='{{len .items}}') == 0 ]]
  do
    echo "[INFO] Waiting..."
    sleep 10
  done
  echo "[INFO] Waiting for ${component} Pod to be ready."
  "${K8S_CLI}" wait --for=condition=ready pod -l app.kubernetes.io/component="${component}" -n "${namespace}" --timeout=120s
}

deleteProductOperatorCSVIfExists
deleteProductOperatorSubscriptionIfExists

if [[ -f "${ORIGINAL_DB_DUMP}" ]]; then
  terminatePostgresConnections
  dropExistingDatabase
  createDatabase
  restoreDatabase
fi

if [[ -f "${ORIGINAL_CHE_CLUSTER_DUMP}" ]]; then
  restoreCheCluster
fi

if "${K8S_CLI}" get subscription "${PRE_MIGRATION_PRODUCT_SUBSCRIPTION_NAME}" -n "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}" > /dev/null 2>&1 ; then
  # rollback is run after 1 or 2 migration steps.
  scaleUpKeycloak
  waitForComponent "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" "${INSTALLATION_NAMESPACE}"
  scaleUpCheServer
  waitForComponent "${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}" "${INSTALLATION_NAMESPACE}"
else
  # rollback is run after 3 or 4 migration steps.
  deleteProductResourcesIfExist
  createPreMigrationProductOperatorSubscription
  waitForComponent "${PRE_MIGRATION_PRODUCT_OPERATOR_NAME}" "${PRE_MIGRATION_PRODUCT_OPERATOR_NAMESPACE}"
  waitForComponent "${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}" "${INSTALLATION_NAMESPACE}"
fi

echo "[INFO] Done."
