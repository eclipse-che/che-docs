---
title: "Multi-User&#58 Deploy to OpenShift"
keywords: openshift, installation, ocp, multi-user, multi user, keycloak, postgres, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-multi-user.html
folder: setup-openshift
---

## Supported OpenShift Flavors and Versions

Multi-user Eclipse Che can be deployed to OpenShift Container Platform 3.6+, OpenShift Dedicated and OpenShift Online Pro.

## Deployment diagram

The deployment script creates 3 DeploymentConfigs for Che, Postgres and Keycloak, as well as PVCs, services and routes (Che and Keycloak only).

{% include image.html file="diagrams/ocp_multi_user.png" %}


## How to Get Deployment YAMLs

```shell
git clone https://github.com/eclipse/che
cd che/deploy/openshift/templates
```

Context of all commands below is `che/deploy/openshift/templates`


## Templates and Parameters

Templates are provided with a set of predefined params which you can override with with `-p key=value`.
You can list all params before applying a template: `oc process --parameters -f <filename>`.
If you miss envs and parameters, you can add them to your template both as a parameters env variables.

Examples below reference `oc-new app` and `oc apply` commands.
`oc new-app` accepts parameters envs or env file which makes it possible to override default params and pass envs to chosen deployments (even if they are not in a template):

```
oc new-app -f example.yaml -p PARAM=VALUE -e ENV=VALUE --env-file=che.env
```
More info is available in [OpenShift documentation](https://docs.openshift.com/container-platform/3.7/dev_guide/application_lifecycle/new_app.html#specifying-a-template).

Env file has a simple format: `KEY=VALUE` per line.

You can also use `oc process` and then apply the resulted output `| oc apply -f -`, for example:

```
oc process -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io | oc apply -f -
```
In this case, however, it is not possible to pass envs, only params are available.

## Minishift

Due to the size of a multi-user Eclipse Che install, MiniShift is not recommended as a base for this configuration. However, if you have to use Minishift ensure you have started MiniShift with `--memory=4096` or more and [update Minishift](https://docs.openshift.org/latest/minishift/getting-started/updating.html) to the latest version.


```bash
oc new-project che

oc new-app -f multi/postgres-template.yaml
oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io
oc apply -f pvc/che-server-pvc.yaml
oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io -p CHE_MULTIUSER=true
oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
```

## OpenShift Container Platform

**HTTP Setup**

```bash
oc new-project che

oc new-app -f multi/postgres-template.yaml
oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX}
oc apply -f pvc/che-server-pvc.yaml
oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} -p CHE_MULTIUSER=true
oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
```

More info about routing suffix [here](openshift-single-user.html#what-is-my-routing-suffix).

**HTTPS Setup**

<span style="color:red;">IMPORTANT!</span> Find instructions on adding self signed certs at [OpenShift Configuration page](openshift-config.html#https-mode---self-signed-certs).

```bash
oc new-project che

oc new-app -f multi/postgres-template.yaml
oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} -p PROTOCOL=https
oc apply -f pvc/che-server-pvc.yaml
oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} \
	-p CHE_MULTIUSER=true \
 	-p PROTOCOL=https \
	-p WS_PROTOCOL=wss \
	-p TLS=true
oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
oc apply -f https
```

More info about routing suffix [here](openshift-single-user.html#what-is-my-routing-suffix).

## OpenShift Dedicated

Instructions to deploy Che to OSD are identical to those for [OpenShift Container Platform](#openshift-container-platform).

## OpenShift Online Pro

Instructions to deploy Che to OSO PRO are identical to those for [OpenShift Container Platform](#openshift-container-platform).

## Admin Guide

See: Kubernetes [Admin Guide][kubernetes-admin-guide]

## What's Next?

Now that you have a running Che Multi-User instance, let's [create a user, setup GitHub oAuth and login][user-management].

{% include links.html %}
