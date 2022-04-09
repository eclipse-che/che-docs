#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}

ALL_USERS_DUMP="${PRODUCT_ID}"-users.txt
MIGRATED_DB_DUMP="${PRODUCT_ID}"-migrated-db.sql

echo "[INFO] Retriving ${PRODUCT_ID} database name."
CHE_POSTGRES_DB=$("${K8S_CLI}" get cm/che -n "${INSTALLATION_NAMESPACE}" -o jsonpath='{.data.CHE_JDBC_URL}' | awk -F '/' '{print $NF}')

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
  echo "[INFO] Uploading ${MIGRATED_DB_DUMP} to the postgreSQL pod."
  "${K8S_CLI}" cp "${MIGRATED_DB_DUMP}" "${INSTALLATION_NAMESPACE}"/"$("${K8S_CLI}" get pods -l app.kubernetes.io/component=postgres -n "${INSTALLATION_NAMESPACE}" --no-headers=true  -o custom-columns=":metadata.name")":/tmp/che.sql

  echo "[INFO] Populating ${CHE_POSTGRES_DB} database with the new content."
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} < /tmp/che.sql"
}

migrateUserProfiles() {
  echo "[INFO] Extract users profiles from ${ALL_USERS_DUMP} and insert them in ${CHE_POSTGRES_DB} database."
  while IFS= read -r line
  do
    IFS=" " read -r -a IDS <<< "${line}"
    OPENSHIFT_USER_ID=${IDS[1]}
    USER_NAME=$(echo "${IDS[2]}" | cut -d ":" -f 2- | base64 -d)
    USER_EMAIL=$(echo "${IDS[3]}" | cut -d ":" -f 2- | base64 -d)
    USER_FIRST_NAME=$(echo "${IDS[4]}" | cut -d ":" -f 2- | base64 -d)
    USER_LAST_NAME=$(echo "${IDS[5]}" | cut -d ":" -f 2- | base64 -d)

    "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} -tAc \"INSERT INTO profile(userid) VALUES ('${OPENSHIFT_USER_ID}');\""
    "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} -tAc \"INSERT INTO profile_attributes(user_id,name, value) VALUES ('${OPENSHIFT_USER_ID}', 'preferred_username', '${USER_NAME}');\""
    "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} -tAc \"INSERT INTO profile_attributes(user_id,name, value) VALUES ('${OPENSHIFT_USER_ID}', 'email', '${USER_EMAIL}');\""
    "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} -tAc \"INSERT INTO profile_attributes(user_id,name, value) VALUES ('${OPENSHIFT_USER_ID}', 'firstName', '${USER_FIRST_NAME}');\""
    "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}"  -- bash  -c "psql ${CHE_POSTGRES_DB} -tAc \"INSERT INTO profile_attributes(user_id,name, value) VALUES ('${OPENSHIFT_USER_ID}', 'lastName', '${USER_LAST_NAME}');\""

    echo "[INFO] Added profile for \"${OPENSHIFT_USER_ID}\"."
  done < "${ALL_USERS_DUMP}"
}

terminatePostgresConnections
dropExistingDatabase
createDatabase
restoreDatabase
migrateUserProfiles

echo "[INFO] Done."
