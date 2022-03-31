#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

K8S_CLI=${K8S_CLI:-oc}                                                           # {orch-cli}
PRODUCT_ID=${PRODUCT_ID:-eclipse-che}                                            # {prod-id}
INSTALLATION_NAMESPACE=${INSTALLATION_NAMESPACE:-eclipse-che}                    # {prod-namespace}
CHE_CLUSTER_CR_NAME=${CHE_CLUSTER_CR_NAME:-eclipse-che}                          # {prod-checluster}

OLM_STABLE_CHANNEL=${OLM_STABLE_CHANNEL:-stable}                                 # {prod-stable-channel}
OLM_CATALOG_SOURCE=${OLM_CATALOG_SOURCE:-community-operators}                    # {prod-stable-channel-catalog-source}
OLM_PACKAGE=${OLM_PACKAGE:-eclipse-che}                                          # {prod-stable-channel-package}

IDENTITY_PROVIDER_DEPLOYMENT_NAME=${IDENTITY_PROVIDER_DEPLOYMENT_NAME:-keycloak} # {?}

while [[ $({orch-cli} get pod -l app.kubernetes.io/component={k8s-component} -n {k8s-namespace} -o go-template='{{len .items}}') == 0 ]]
do
  echo "Waiting..."
  sleep 10s
done
{orch-cli} wait --for=condition=ready pod -l app.kubernetes.io/component={k8s-component} -n {k8s-namespace} --timeout=120s

echo "[INFO] Done."
