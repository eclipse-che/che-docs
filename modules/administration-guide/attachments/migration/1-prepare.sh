#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}

PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME=${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME:-che}      # {pre-migration-prod-deployment}
PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME=${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME:-eclipse-che}                          # {pre-migration-prod-checluster}
PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME=${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME:-keycloak} # {identity-provider-id}

ALL_USERS_DUMP="${PRODUCT_ID}"-users.txt
DB_DUMP="${PRODUCT_ID}"-original-db.sql
MIGRATED_DB_DUMP="${PRODUCT_ID}"-migrated-db.sql

echo "[INFO] Getting identity provider information"

IDENTITY_PROVIDER_URL=$("${K8S_CLI}" get checluster "${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.status.keycloakURL}" )
IDENTITY_PROVIDER_SECRET=$("${K8S_CLI}" get checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.spec.auth.identityProviderSecret}")
IDENTITY_PROVIDER_PASSWORD=$(if [ -z "${IDENTITY_PROVIDER_SECRET}" ] || [ "${IDENTITY_PROVIDER_SECRET}" == "null" ]; then "${K8S_CLI}" get checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}"  -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.spec.auth.identityProviderPassword}"; else "${K8S_CLI}" get secret "${IDENTITY_PROVIDER_SECRET}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.data.password}" | base64 -d; fi)
IDENTITY_PROVIDER_USERNAME=$(if [ -z "${IDENTITY_PROVIDER_SECRET}" ] || [ "${IDENTITY_PROVIDER_SECRET}" == "null" ]; then "${K8S_CLI}" get checluster/"${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}"  -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.spec.auth.IdentityProviderAdminUserName}"; else "${K8S_CLI}" get secret "${IDENTITY_PROVIDER_SECRET}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.data.user}" | base64 -d; fi)
IDENTITY_PROVIDER_REALM=$("${K8S_CLI}" get checluster "${PRE_MIGRATION_PRODUCT_CHE_CLUSTER_CR_NAME}" -n "${INSTALLATION_NAMESPACE}" -o jsonpath="{.spec.auth.identityProviderRealm}")

echo "[INFO] IDENTITY_PROVIDER_URL: ${IDENTITY_PROVIDER_URL}"
echo "[INFO] IDENTITY_PROVIDER_SECRET: ${IDENTITY_PROVIDER_SECRET}"
echo "[INFO] IDENTITY_PROVIDER_USERNAME: ${IDENTITY_PROVIDER_USERNAME}"
echo "[INFO] IDENTITY_PROVIDER_REALM: ${IDENTITY_PROVIDER_REALM}"

sed_in_place() {
    SHORT_UNAME=$(uname -s)
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' "$@"
  elif [ "${SHORT_UNAME:0:5}" == "Linux" ]; then
    sed -i "$@"
  fi
}

refreshToken() {
  echo "[INFO] Refreshing identity provider token"
  IDENTITY_PROVIDER_TOKEN=$(curl -ks \
    -d "client_id=admin-cli" \
    -d "username=${IDENTITY_PROVIDER_USERNAME}" \
    -d "password=${IDENTITY_PROVIDER_PASSWORD}" \
    -d "grant_type=password" \
    "${IDENTITY_PROVIDER_URL}/realms/master/protocol/openid-connect/token" | jq -r ".access_token")
}

scaleDownCheServer() {
  echo "[INFO] Scaling down ${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}"
  "${K8S_CLI}" scale deployment "${PRE_MIGRATION_PRODUCT_DEPLOYMENT_NAME}" --replicas=0 -n "${INSTALLATION_NAMESPACE}"
}

scaleDownKeycloak() {
  echo "[INFO] Scaling down ${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}"
  "${K8S_CLI}" scale deployment "${PRE_MIGRATION_PRODUCT_IDENTITY_PROVIDER_DEPLOYMENT_NAME}" --replicas=0 -n "${INSTALLATION_NAMESPACE}"
}

getUsers() {
  rm -f "${ALL_USERS_DUMP}"
  refreshToken
  echo "[INFO] Dumping users list in file ${ALL_USERS_DUMP}"

  TOTAL=0
  FIRST=0
  MAX=100

  while :
  do
    ALL_USERS=$(curl -ks  -H "Authorization: bearer ${IDENTITY_PROVIDER_TOKEN}" "${IDENTITY_PROVIDER_URL}/${IDENTITY_PROVIDER_USERNAME}/realms/${IDENTITY_PROVIDER_REALM}/users?first=${FIRST}&max=${MAX}")
    IFS=" " read -r -a ALL_USERS_IDS <<< "$(echo "${ALL_USERS}" | jq ".[] | .id" | tr "\r\n" " ")"

    # break the cycle if page is empty
    [[ ${#ALL_USERS_IDS[@]} == 0 ]] && break

    for USER_ID in "${ALL_USERS_IDS[@]}"; do
        refreshToken

        USER_ID=$(echo "${USER_ID}" | tr -d "\"")
        FEDERATED_IDENTITY=$(curl -ks -H "Authorization: bearer ${IDENTITY_PROVIDER_TOKEN}" "${IDENTITY_PROVIDER_URL}/${IDENTITY_PROVIDER_USERNAME}/realms/${IDENTITY_PROVIDER_REALM}/users/${USER_ID}/federated-identity")
        IDENTITY_PROVIDER=$(echo "${FEDERATED_IDENTITY}" | jq -r ".[] | select(.identityProvider == \"openshift-v4\")")
        if [ -n "${IDENTITY_PROVIDER}" ]; then
          USER_PROFILE=$(echo "${ALL_USERS}" | jq -r ".[] | select(.id == \"${USER_ID}\")")
          USER_EMAIL=$(echo "${USER_PROFILE}" | jq -r ".email")
          USER_NAME=$(echo "${USER_PROFILE}" | jq -r ".username")
          USER_FIRST_NAME=$(echo "${USER_PROFILE}" | jq -r ".firstName")
          USER_LAST_NAME=$(echo "${USER_PROFILE}" | jq -r ".lastName")

          # Don't put null values into profile
          [[ "${USER_FIRST_NAME}" == "null" ]] && USER_FIRST_NAME=""
          [[ "${USER_LAST_NAME}" == "null" ]] && USER_LAST_NAME=""

          OPENSHIFT_USER_ID=$(echo "${IDENTITY_PROVIDER}" | jq ".userId" | tr -d "\"")
          echo "[INFO] Found ${PRODUCT_ID} user: ${USER_ID} and corresponding OpenShift user: ${OPENSHIFT_USER_ID}"

          # Save profile by encoding data and trimming \r\n
          echo "${USER_ID} ${OPENSHIFT_USER_ID} username:$(echo "${USER_NAME}" | tr -d "\r\n" | base64) email:$(echo "${USER_EMAIL}" | tr -d "\r\n" | base64) firstName:$(echo "${USER_FIRST_NAME}" | tr -d "\r\n" | base64) lastName:$(echo "${USER_LAST_NAME}" | tr -d "\r\n" | base64) " >> "${ALL_USERS_DUMP}"
          TOTAL=$((TOTAL+1))
        else
          echo "[WARN] Ignored ${PRODUCT_ID} user: ${USER_ID}. Corresponding OpenShift user not found."
        fi
    done

    FIRST=$((FIRST + MAX))
  done

  echo "[INFO] Users list dump completed. Found ${TOTAL} users."
}

dumpDB() {
  echo "[INFO] Dumping database in file ${DB_DUMP}"

  echo "[INFO] Retrieving database name"
  CHE_POSTGRES_DB=$("${K8S_CLI}" get cm/che -n "${INSTALLATION_NAMESPACE}" -o jsonpath='{.data.CHE_JDBC_URL}' | awk -F '/' '{print $NF}')
  if [ -z "${CHE_POSTGRES_DB}" ] || [ "${CHE_POSTGRES_DB}" = "null" ]; then CHE_POSTGRES_DB="dbche"; fi
  echo "[INFO] Database name is ${CHE_POSTGRES_DB}"

  echo "[INFO] Executing pg_dump"
  "${K8S_CLI}" exec deploy/postgres -n "${INSTALLATION_NAMESPACE}" -- bash  -c "pg_dump $CHE_POSTGRES_DB > /tmp/che.sql"

  echo "[INFO] Downloading the dump"
  "${K8S_CLI}" cp "${INSTALLATION_NAMESPACE}"/"$("${K8S_CLI}" get pods -l app.kubernetes.io/component=postgres -n "${INSTALLATION_NAMESPACE}" --no-headers=true  -o custom-columns=":metadata.name")":/tmp/che.sql "${DB_DUMP}" > /dev/null

  echo "[INFO] Database dump completed"
}

replaceUserIDsInDBDump() {
  echo "[INFO] Replacing USER_IDs in ${DB_DUMP} and saving it in ${MIGRATED_DB_DUMP}."
  cp "${DB_DUMP}" "${MIGRATED_DB_DUMP}"
  while IFS= read -r line
  do
    IFS=" " read -r -a IDS <<< "${line}"
    USER_ID=${IDS[0]}
    OPENSHIFT_USER_ID=${IDS[1]}

    sed_in_place -e "s|${USER_ID}|${OPENSHIFT_USER_ID}|g" "${MIGRATED_DB_DUMP}"

    echo "[INFO] Replaced User ID \"${USER_ID}\" with \"${OPENSHIFT_USER_ID}\"."
  done < "${ALL_USERS_DUMP}"
  echo "[INFO] USER_IDs replaced."
}

scaleDownCheServer
getUsers
scaleDownKeycloak
dumpDB
replaceUserIDsInDBDump

echo "[INFO] Done."
