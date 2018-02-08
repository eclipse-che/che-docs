---
title: "Single-User&#58 Deploy to OpenShift"
keywords: openshift, installation, pvc, https, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-single-user.html
folder: setup-openshift
---
## Supported OpenShift Flavors and Versions

Che can be deployed to MiniShift, OCP, OSD and OSO v3.5+.

## Pre-Reqs

* [jq](https://stedolan.github.io/jq/) utility
* `bash`

Scripts will use default settings for things like Che project name, http/https protocol, log level etc. See: [OpenShift config][openshift-config]

## Deployment Diagram

There are a few essential Kubernetes and OpenShift objects that are created when Che is deployed to OpenShift. When a workspace is started additional objects are created. See the diagram below:

{% include image.html file="diagrams/ocp_single_user.png" %}

This diagram depicts the default [PVC strategy](openshift-config.html#volumes) (PVC per workspace).

## MiniShift

**MiniShift Addon**

The best way of deploying Che to MiniShift is using an add-on via the [`minishift add-ons apply`](https://docs.openshift.org/latest/minishift/command-ref/minishift_addons_apply.html) command which is outlined in the following paragraphs.

**Install add-On**

Clone addons repository onto your local machine and then install the add-on via:

```
git clone https://github.com/minishift/minishift-addons
minishift addons install <path_to_minishift-addons>/add-ons/che
minishift addons enable che
```

`enable` will setup Eclipse Che when you start Minishift the next time.

**Apply add-on**

If Minishift is already started and Che addon is installed, it is possible to deploy Che without restarting Minishift:


```bash
$ minishift addons apply \
    --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:nightly \
    --addon-env OPENSHIFT_TOKEN=$(oc whoami -t) \
    che
```

**Deploy a local Che server image**

To deploy a local che-server image (e.g. `eclipse/che-server:local`) based on Che v5:

```bash
$ minishift addons apply --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:local che
```

If the local image is based on Che v6:

```bash
$ minishift addons apply \
    --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:local \
    --addon-env OPENSHIFT_TOKEN=$(oc whoami -t) \
    che
```

**Addon Variables**

To customize the deployment of the Che server, the following variables can be applied to the execution:

|Name|Description|Default Value|
|----|-----------|-------------|
|`NAMESPACE`|The OpenShift project where Che service will be deployed|`che-mini`|
|`CHE_DOCKER_IMAGE`|The docker image to be used for che.|`eclipse/che-server:latest`|
|`GITHUB_CLIENT_ID`|GitHub client ID to be used in Che workspaces|`changeme`|
|`GITHUB_CLIENT_SECRET`|GitHub client secred to be used in Che workspaces|`changeme`|
|`OPENSHIFT_TOKEN`|For Che v6 only. The token to create workspace resources (pods, services, routes, etc...)|`changeme`|

Variables can be specified by adding `--addon-env <key=value>` when the addon is being invoked (either by `minishift start` or `minishift addons apply`).

**Remove add-on**

To remove all created template and che project:

```bash
minishift addons remove \
--addon-env OPENSHIFT_TOKEN="" \
--addon-env CHE_DOCKER_IMAGE="" \
--addon-env GITHUB_CLIENT_ID="" \
--addon-env GITHUB_CLIENT_SECRET="" \
--addon-env NAMESPACE=mini-che che
```

**Uninstall add-on**

To uninstall the addon from the addon list:

`minishift addons uninstall che`

**Script-based method:**

Alternatively, you may download and run deployment scripts instead of using MiniShift addons:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
bash ./get-che.sh
```

## OpenShift Container Platform

* Use environment variables to set [deployment options][openshift-config]:

```shell
export OPENSHIFT_ENDPOINT=<OCP_ENDPOINT_URL> # e.g. https://api.pro-us-east-1.openshift.com for OpenShift Online Pro
export OPENSHIFT_TOKEN=<OCP_TOKEN> # it depends on authentication scheme for your OCP cluster - it can also be CHE_INFRA_KUBERNETES_USERNAME and CHE_INFRA_KUBERNETES_PASSWORD instead
export OPENSHIFT_ROUTING_SUFFIX=<ROUTING-SUFFIX> # e.g. yourDomain.router.com or b9ad.pro-us-east-1.openshiftapps.com for OpenShift Online Pro East Region
export ENABLE_SSL=false # true by default. Set to false if you have self signed certs
export OPENSHIFT_FLAVOR=ocp
```

* Download and run deployment script:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
bash ./get-che.sh
```

## OpenShift Dedicated

Instructions to deploy Che to OSD are identical to those for [OpenShift Container Platform](#openshift-container-platform)

## Openshift.io

Please note that deploying Che on [OpenShift.io](https://openshift.io) (OSIO) is only intended for Che developers and OSIO contributors. This is useful when a developer wants to test how changes will work on [OpenShift.io](https://openshift.io). If you are interested in using OpenShift.io you can [sign up](https://openshift.io/) for the service.

Use environment variables to set [deployment options][openshift-config]:

```shell
export OPENSHIFT_TOKEN=<OSO_TOKEN> # Retrieve the OSO_TOKEN from https://console.starter-us-east-2.openshift.com/console/command-line
export OPENSHIFT_FLAVOR=osio
```

Download and run deployment script:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
bash ./get-che.sh
```

## Deployment Options and Configuration

See: [OpenShift Deployment Config][openshift-config]

{% include links.html %}
