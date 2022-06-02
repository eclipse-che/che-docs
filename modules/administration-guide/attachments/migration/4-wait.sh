#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                   # {orch-cli}
PRODUCT_DEPLOYMENT_NAME=${PRODUCT_DEPLOYMENT_NAME:-che}                  # {prod-deployment}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}            # {prod-namespace}
PRODUCT_OPERATOR_NAME=${PRODUCT_OPERATOR_NAME:-che-operator}             # {prod-operator}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-openshift-operators}            # {?}

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
  "${K8S_CLI}" wait --for=condition=ready pod -l app.kubernetes.io/component="${component}" -n "${namespace}" --timeout=240s
}

waitForComponent "${PRODUCT_OPERATOR_NAME}" "${OPERATOR_NAMESPACE}"
waitForComponent "${PRODUCT_DEPLOYMENT_NAME}" "${INSTALLATION_NAMESPACE}"

echo "[INFO] Done."
