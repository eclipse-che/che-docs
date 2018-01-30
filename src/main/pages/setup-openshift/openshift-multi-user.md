---
title: "Multi-User&#58 Deploy to OpenShift"
keywords: openshift, installation, ocp, multi-user, multi user, keycloak, postgres, s2i, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-multi-user.html
folder: setup-openshift
---

## Deployment diagram

Deployment of a multi-user Che is a bit more complicated as Keycloak and Postgres images need to be provisioned with the right configuration. On top of that, pods need to start in a particular order: **Postgres-Keycloak-Che**. To accomplish this task, the deployment script makes use of OpenShift S2I build strategy - BuildConfigs and ImageStreams are created first. S2I builds grab official Keycloak and Postgres images, copy necessary configuration files that come with `eclipse/che-init` image and save resulting images as ImageStreams that are then referenced in corresponding DeploymentConfigs. When builds succeed, the script continues with deployment.

{% include image.html file="diagrams/ocp_multi_user.png" %}

## Using Existing Keycloak

To prevent deployment script from creating a deployment for Keycloak, set the following env before running `deploy-che.sh`:

`CHE_DEDICATED_KEYCLOAK=false`

You will also need a few additional envs, as well as proper realm and client configuration for Keycloak. See: [OpenShift configuration](openshift-config.html#multi-user-using-own-keycloak-and-psql).

If your Keycloak server has `http` endpoint and Che server is deployed with `https` route, Keycloak script won't be injected into Che page, since browsers will block loading insecure content into a secure page.

## How to Get Scripts

There are two ways to get deployment scripts: either clone Che or run a Docker image:

```shell
git clone https://github.com/eclipse/che
cd che/dockerfiles/init/modules/openshift/files/scripts
```
or

```shell
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v ${LOCAL_PATH}:/data eclipse/che init
cd ${LOCAL_PATH}/instance/config/openshift/scripts
```

## MiniShift

```
export CHE_MULTIUSER=true
./deploy_che.sh && ./wait_until_che_is_available.sh

```
## OpenShift Container platform

```bash
export CHE_MULTIUSER=true
export OPENSHIFT_ENDPOINT=<OCP_ENDPOINT_URL> # e.g. https://opnshmdnsy3t7twsh.centralus.cloudapp.azure.com:8443
export OPENSHIFT_TOKEN=<OCP_TOKEN> # it depends on authentication scheme for your OCP cluster - it can also be OPENSHIFT_USERNAME and OPENSHIFT_PASSWORD instead
export OPENSHIFT_ROUTING_SUFFIX=<ROUTING-SUFFIX> # e.g. yourDomain.router.com
export ENABLE_SSL=false # true by default. Set to false if you have self signed certs
export OPENSHIFT_FLAVOR=ocp
./deploy_che.sh && ./wait_until_che_is_available.sh
```
In both cases, you can additionally run `replace_stacks.sh` that will replace Che upstream stacks with the ones currently used in OSIO flavored Che.

## OpenShift Dedicated

Instructions to deploy Che to OSD are identical to those for [OpenShift Container Platform](#openshift-container-platform)

{% include links.html %}
