---
title: "Single-User&#58 Deploy to OpenShift"
keywords: openshift, installation, pvc, https, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-single-user.html
folder: setup-openshift
---
## Supported OpenShift Flavors and Versions

Single User Eclipse Che can be deployed to Minishift, OCP, OSD and OSO v3.6+.

## Pre-Requisites

OpenShift oc client installed locally

## Admin Guide

See: [Kubernetes Admin Guide][kubernetes-admin-guide]

## Deployment Diagram

There are a few essential Kubernetes and OpenShift objects that are created when Che is deployed to OpenShift. When a workspace is started additional objects are created. See the diagram below:

{% include image.html file="diagrams/ocp_single_user.png" %}

This diagram depicts the default [PVC strategy](openshift-config.html#volumes) (PVC per workspace).

## Minishift Addon

Before starting [install Minishift](https://docs.openshift.org/latest/minishift/getting-started/installing.html) or [update your Minishift](https://docs.openshift.org/latest/minishift/getting-started/updating.html) to ensure you're on the most up-to-date version.

**Minishift Addon**

The best way of deploying Che to Minishift is using an add-on via the [`minishift add-ons apply`](https://docs.openshift.org/latest/minishift/command-ref/minishift_addons_apply.html) command which is outlined in the following paragraphs.

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

Variables can be specified by adding `--addon-env <key=value>` when the addon is being invoked (either by `minishift start` or `minishift addons apply`).

**Remove add-on**

To remove all created template and che project:

```bash
minishift addons remove che
```

**Uninstall add-on**

To uninstall the addon from the addon list:

`minishift addons uninstall che`


## What is my routing suffix?

Deployment methods below will require a valid routing suffix to be passed as a template parameter.

By default `oc cluster up` command uses `nip.io` as wildcard DNS provider, so your routing suffix will be `$IP.nip.io`.
A routing suffix can be provided when a cluster starts. If you have existing routes in your OpenShift installation, you can extract ROUTING_SUFFIX.
A route has the following format: `${route}-${namespace}.${ROUTING_SUFFIX}`.
On MiniShift your ROUTING_SUFFIX will be `$(minishift ip).nip.io`.

Here's a few simple commands to get your routing suffix:

```
oc create service clusterip test --tcp=80:80
oc expose service test
oc get route test -o=jsonpath='{.spec.host}{"\n"}'
```

Everything that comes after namespace in a route URL is your routing suffix. Don't forget to delete test service and route.

## MiniShift: Templates

Alternatively, you may download templates and run deployment manually instead of using MiniShift addons:

```shell
# get yamls

DEPLOY_ROOT_URL=https://raw.githubusercontent.com/eclipse/che/master/deploy/openshift/templates
curl -fsSL ${DEPLOY_ROOT_URL}/che-server-template.yaml -o che-server-template.yaml
curl -fsSL ${DEPLOY_ROOT_URL}/pvc/che-server-pvc.yaml -o che-server-pvc.yaml

# create a project
oc new-project che

oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io
oc apply -f pvc/che-server-pvc.yaml
oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
```

## HTTPS Mode

<span style="color:red;">IMPORTANT!</span> Find instructions on adding self signed certs at [OpenShift Configuration page](openshift-config.html#https-mode---self-signed-certs).


```
oc new-project che

oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io \
                                       -p PROTOCOL=https \
                                       -p WS_PROTOCOL=wss \
                                       -p TLS=true
oc apply -f pvc/che-server-pvc.yaml
oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
oc apply -f https/che-route-tls.yaml
```

## OpenShift Container Platform

Same instructions as in [MiniShift](#minishift-templates), however, you need to provide a valid [ROUTING_SUFFIX](#what-is-my-routing-suffix).

## OpenShift Dedicated

Instructions to deploy Che to OSD are identical to those for [OpenShift Container Platform](#openshift-container-platform)

## OpenShift Online

Instructions to deploy Che to OSO Pro are identical to those for [OpenShift Container Platform](#openshift-container-platform)

## Deployment Options and Configuration

See: [OpenShift Deployment Config][openshift-config] and [Admin Guide][kubernetes-admin-guide]

## What's Next

Create and [start your first workspace][creating-starting-workspaces], [import a project][version-control].

{% include links.html %}
