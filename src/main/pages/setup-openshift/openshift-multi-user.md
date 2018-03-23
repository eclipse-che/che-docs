---
title: "Multi-User&#58 Deploy to OpenShift"
keywords: openshift, installation, ocp, multi-user, multi user, keycloak, postgres, s2i, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-multi-user.html
folder: setup-openshift
---

## Supported OpenShift Flavors and Versions

Multi-user Eclipse Che can be deployed to OpenShift Container Platform 3.6+, OpenShift Dedicated and OpenShift Online Pro.

## System Requirements

Eclipse Che requires **OpenShift 3.6** or higher. Your OpenShift node should have at least 5GB RAM available - 3GB go to Che deployments and 2GB is reserved to run at least one workspace. The total RAM required for running workspaces will grow depending on the size of your workspace runtime(s) and the number of concurrent workspace pods you run.

## Deployment diagram

The deployment script creates 3 DeploymentConfigs for Che, Postgres and Keycloak, as well as PVCs, services and routes (Che and Keycloak only). Once deployments are completed, a special service pod is started to configure Keycloak with realm, client and a default user. Client is provided with the right redirectUris and webOrigins. This pod gets deployed only in case an out-of-the-box Keycloak is used.

{% include image.html file="diagrams/ocp_multi_user.png" %}

## Using Existing Keycloak

To prevent deployment script from creating a deployment for Keycloak, set the following env before running `deploy-che.sh`:

`CHE_DEDICATED_KEYCLOAK=false`

You will also need a few additional envs, as well as proper realm and client configuration for Keycloak. See: [OpenShift configuration](openshift-config.html#multi-user-using-own-keycloak-and-psql).

If your Keycloak server has `http` endpoint and Che server is deployed with `https` route, Keycloak script won't be injected into Che page, since browsers will block loading insecure content into a secure page.

## How to Get Scripts


```shell
git clone https://github.com/eclipse/che
cd che/deploy/openshift
```

## Minishift

Due to the size of a multi-user Eclipse Che install, Minishift is not recommended as a base for this configuration. However, if you have to use Minishift ensure you have started Minishift with `--memory=4096` or more and [update Minishift](https://docs.openshift.org/latest/minishift/getting-started/updating.html) to the latest version.

```bash
export CHE_MULTIUSER=true
export WAIT_FOR_CHE=true
./deploy_che.sh
```


## OpenShift Container Platform

```bash
export CHE_MULTIUSER=true
export OPENSHIFT_ENDPOINT=<OCP_ENDPOINT_URL> # e.g. https://api.pro-us-east-1.openshift.com for OpenShift Online Pro
export OPENSHIFT_TOKEN=<OCP_TOKEN> # it depends on authentication scheme for your OCP cluster - it can also be OPENSHIFT_USERNAME and OPENSHIFT_PASSWORD instead
export OPENSHIFT_ROUTING_SUFFIX=<ROUTING-SUFFIX> # e.g. yourDomain.router.com or b9ad.pro-us-east-1.openshiftapps.com for OpenShift Online Pro East Region
export ENABLE_SSL=false # true by default. Set to false if you have self signed certs
export OPENSHIFT_FLAVOR=ocp
export WAIT_FOR_CHE=true
./deploy_che.sh
```

**IMPORTANT!**

If you provide a **token** rather than username/password, Che will use this token in the deployment script to login in and create all [Che infrastructure objects](#deployment-diagram), as well as when creating workspace pods and associated objects. A token may expire due to expiration timeout policy or it can be invalidated when a new token is requested. In this case, Fabric8 client library that Che uses to communicate with OpenShift will fail to create an object with this bad token and fall back to using a service account instead. There are two options here:

1. Set identical values for `CHE_OPENSHIFT_PROJECT` and `CHE_INFRA_OPENSHIFT_PROJECT`. In this case Che server pod and workspace pods will be created in the same namespace, thus, `che` service account will have permissions to create objects in this namespace's scope.
2. If you are a cluster admin, you may grant privileges to `che` service account so that it can create objects outside its namespace:

```bash
oadm policy add-cluster-role-to-user self-provisioner system:serviceaccount:eclipse-che:che

# eclipse-che is the default namespace where Che server objects are created.
# It can be overridden by `CHE_OPENSHIFT_PROJECT`
```

## OpenShift Dedicated

Instructions to deploy Che to OSD are identical to those for [OpenShift Container Platform](#openshift-container-platform)

## OpenShift Online Pro

Below is a recommended way to deploy Eclipse Che multi-user on OpenShift Online Pro (OpenShift Online Starter does not have sufficient resources to run multi-user Che):

```bash
export CHE_MULTIUSER=true
export OPENSHIFT_ENDPOINT=https://api.rh-us-east-1.openshift.com
export OPENSHIFT_TOKEN=bLAa-4dWUaixiUieOeVdynAB1QDmaJzrazepHEF431c
export CHE_INFRA_KUBERNETES_OAUTH__TOKEN=""
export OPENSHIFT_ROUTING_SUFFIX=6923.rh-us-east-1.openshiftapps.com
export OPENSHIFT_FLAVOR=ocp
export IMAGE_PULL_POLICY=Always
export CHE_OPENSHIFT_PROJECT=eclipse-che
export CHE_INFRA_OPENSHIFT_PROJECT=eclipse-che
export WAIT_FOR_CHE=true

cd che/deploy/openshift

echo "CHE_INFRA_KUBERNETES_PVC_QUANTITY: \"1Gi\"" >> che-config

./deploy_che.sh
```

A few gotchas:

* `CHE_OPENSHIFT_PROJECT` may be already used by another namespace. In this case, set it to have some unique value
* `CHE_INFRA_OPENSHIFT_PROJECT` should be the same as `CHE_OPENSHIFT_PROJECT` which means all workspace objects will be created in the same s=namespace with Che server.
This is a prerequisite to use service account rather than a token that may get expired or invalidated
* You need to obtain and export `OPENSHIFT_TOKEN`. Deployment script will use it to login to your OSO account and deploy Che
* `CHE_INFRA_KUBERNETES_OAUTH__TOKEN` should have an empty value. This way, `che` service account will be used to create workspace objects
* `CHE_INFRA_KUBERNETES_PVC_QUANTITY`: use reasonable minimal values for your OSO account in order not to exceed quotas


## What's Next?

Now that you have a running Che Multi-User instance, let's [create a user, setup GitHub oAuth and login][user-management].

{% include links.html %}
