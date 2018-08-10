---
title: "Multi-User&#58 Deploy to OpenShift"
keywords: openshift, installation, ocp, multi-user, multi user, keycloak, postgres, deployment
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-multi-user.html
folder: setup-openshift
---

## Deploying Che on supported OpenShift flavors and versions

Multi-user Eclipse Che can be deployed to OpenShift Container Platform 3.6 and later, OpenShift Dedicated, and OpenShift Online Pro.

The deployment script creates three DeploymentConfigs for Che, Postgres, and Keycloak.  PVCs, services, and routes (Che and Keycloak only) are also created by the deployment script.

## Deployment diagram

{% include image.html file="diagrams/ocp_multi_user.png" %}


## Getting deployment YAML files

```shell
$ git clone https://github.com/eclipse/che
$ cd che/deploy/openshift/templates
```

The context of all commands below is `che/deploy/openshift/templates`.

## Using templates and modifying their parameters

Templates are provided with a set of predefined parameters. You can add parameters and environment variables to your template. You can also override parameters by using this option: `-p key=value`. The `oc new-app` command accepts parameters, environment variables, or environment files, which makes it possible to override default parameters and pass environment variables to chosen deployments (even if they are not in a template). You can view all parameters by using this command: `$ oc process --parameters -f <filename>`.

The examples below reference the `oc process`, `oc-new app`, and `oc apply` commands.

```
$ oc new-app -f example.yaml -p PARAM=VALUE -e ENV=VALUE --env-file=che.env
```

The environment file has a simple format: `KEY=VALUE` per line.

In the following example, you can use the `oc process` command and then apply the resulting output by adding `| oc apply -f -`, for example:

```
$ oc process -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io | oc apply -f -
```

In this case, it is not possible to pass environment variables; only parameters are available.

## Using Minishift to deploy Che

Due to the size of a multi-user Eclipse Che installation, Minishift is not recommended as the base for this configuration.  If you have to use Minishift, start it with at least 4GB of memory by including the `--memory=4096` parameter, and [update Minishift](https://docs.openshift.org/latest/minishift/getting-started/updating.html) to the latest version.


```bash
$ oc new-project che
$ oc new-app -f multi/postgres-template.yaml
$ oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io
$ oc apply -f pvc/che-server-pvc.yaml
$ oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=$(minishift ip).nip.io -p CHE_MULTIUSER=true
$ oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
```

## Using OpenShift Container Platform to deploy Che 

**HTTP Setup**

```bash
$ oc new-project che
$ oc new-app -f multi/postgres-template.yaml
$ oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX}
$ oc apply -f pvc/che-server-pvc.yaml
$ oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} -p CHE_MULTIUSER=true
$ oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
```

More information about the [routing suffix](openshift-single-user.html#what-is-my-routing-suffix).

**HTTPS Setup**

<span style="color:red;">IMPORTANT!</span> Find instructions on adding self-signed certificates at the [OpenShift Configuration page](openshift-config.html#https-mode---self-signed-certs).

```bash
$ oc new-project che
$ oc new-app -f multi/postgres-template.yaml
$ oc new-app -f multi/keycloak-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} -p PROTOCOL=https
$ oc apply -f pvc/che-server-pvc.yaml
$ oc new-app -f che-server-template.yaml -p ROUTING_SUFFIX=${ROUTING_SUFFIX} \
	-p CHE_MULTIUSER=true \
 	-p PROTOCOL=https \
	-p WS_PROTOCOL=wss \
	-p TLS=true
$ oc set volume dc/che --add -m /data --name=che-data-volume --claim-name=che-data-volume
$ oc apply -f https
```

More information about the [routing suffix](openshift-single-user.html#what-is-my-routing-suffix).

## Using OpenShift Dedicated to deploy Che

The instructions to deploy Che to OpenShift Dedicated are identical to those for [OpenShift Container Platform](#openshift-container-platform).

## Using OpenShift Online Pro to deploy Che

The instructions to deploy Che to OpenShift Online PRO are identical to those for [OpenShift Container Platform](#openshift-container-platform).

## What is next?

Now that you have a running Che multi-user instance, [create a user, set up GitHub oAuth, and log in][user-management].

## Additional Resources

Kubernetes [Admin Guide][kubernetes-admin-guide]

[OpenShift documentation](https://docs.openshift.com/container-platform/3.7/dev_guide/application_lifecycle/new_app.html#specifying-a-template) 

{% include links.html %}
