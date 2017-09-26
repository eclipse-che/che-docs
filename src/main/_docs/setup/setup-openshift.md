---
tags: [ "eclipse" , "che" ]
title: OpenShift Installation
excerpt: "Run Che on OpenShift."
layout: docs
permalink: /:categories/openshift/
---
{% include base.html %}

You can run the Che server and its workspaces with [OpenShift](https://www.openshift.com/). OpenShift is built on top of Kubernetes and has a built-in Docker registry, reverse proxy and OAuth server. OpenShift can be used to deploy Che as enterprise-wide cloud IDE.

We currently support Che deployment for the following OpenShift flavours:

- [OpenShift Container Platform](#deploy-che-on-openshift-container-platform)
- [Minishift](#deploy-che-on-minishift)
- [Openshift.io](#deploy-che-on-openshiftio) (only for developing Che itself)

# Deploy Che on OpenShift Container Platform

Use environment variables to set [deployment options](#deployment-options):

```shell
export OPENSHIFT_ENDPOINT=<OCP_ENDPOINT_URL> # e.g. https://opnshmdnsy3t7twsh.centralus.cloudapp.azure.com:8443
export OPENSHIFT_TOKEN=<OCP_TOKEN>
export OPENSHIFT_NAMESPACE_URL=<CHE_HOSTNAME> # e.g. che-eclipse-che.52.173.199.80.xip.io
export OPENSHIFT_FLAVOR=ocp
```

Download and run deployment scripts:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
WAIT_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/wait_until_che_is_available.sh
STACKS_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/replace_stacks.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
curl -fsSL ${WAIT_SCRIPT_URL} -o ./wait-che.sh
curl -fsSL ${STACKS_SCRIPT_URL} -o ./stacks-che.sh
bash ./get-che.sh && bash ./wait-che.sh && bash ./stacks-che.sh
```

# Deploy Che on Minishift

Download and run deployment scripts:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
WAIT_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/wait_until_che_is_available.sh
STACKS_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/replace_stacks.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
curl -fsSL ${WAIT_SCRIPT_URL} -o ./wait-che.sh
curl -fsSL ${STACKS_SCRIPT_URL} -o ./stacks-che.sh
bash ./get-che.sh && bash ./wait-che.sh && bash ./stacks-che.sh
```

# Deploy Che on openshift.io

Please note that deploying Che on [OpenShift.io](openshift.io) (OSIO) is only intended for Che developers and OSIO contributors. This is useful when a developer wants to test how changes will work on [OpenShift.io](openshift.io). If you are interested in using OpenShift.io you can [sign up](https://openshift.io/) for the service.

Use environment variables to set [deployment options](#deployment-options):

```shell
export OPENSHIFT_TOKEN=<OSO_TOKEN> # Retrieve the OSO_TOKEN from https://console.starter-us-east-2.openshift.com/console/command-line
export OPENSHIFT_FLAVOR=osio
```

Download and run deployment scripts:

```shell
DEPLOY_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/deploy_che.sh
WAIT_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/wait_until_che_is_available.sh
STACKS_SCRIPT_URL=https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/replace_stacks.sh
curl -fsSL ${DEPLOY_SCRIPT_URL} -o ./get-che.sh
curl -fsSL ${WAIT_SCRIPT_URL} -o ./wait-che.sh
curl -fsSL ${STACKS_SCRIPT_URL} -o ./stacks-che.sh
bash ./get-che.sh && bash ./wait-che.sh && bash ./stacks-che.sh
```

# Deployment Options

You can set different deployment options using environment variables:

* `OPENSHIFT_FLAVOR`: Possible values are `ocp`, `minishift` and `osio` (default is `minishift`)
* `OPENSHIFT_ENDPOINT`: URL of the OpenShift API (default is unset for ocp, `https://$(minishift ip):8443/` for minishift, `https://api.starter-us-east-2.openshift.com` for osio)
* `OPENSHIFT_TOKEN` (default is unset)
* `CHE_OPENSHIFT_PROJECT`: The OpenShift namespace where Che will be deployed (default is `eclipse-che` for ocp and minishift and `${OPENSHIFT_ID}-che` for osio)
* `CHE_IMAGE_REPO`: `che-server` Docker image repository that will be used for deployment (default is `docker.io/eclipse/che-server`)
* `CHE_IMAGE_TAG`: `che-server` Docker image tag that will be used for deployment (default is `nightly-centos`)
* `CHE_LOG_LEVEL`: Logging level of output for Che server. Can be `debug` or `info` (default is `DEBUG`)
* `CHE_DEBUGGING_ENABLED`: If set to `true` the script will create the OpenShift service to debug che-server (default is `true`)
* `CHE_KEYCLOAK_DISABLED`: If this is set to true Keycloack authentication will be disabled (default is `true` for ocp and minishift, `false` for osio)
* `OPENSHIFT_NAMESPACE_URL`: The Che application hostname (default is unset for ocp, `${CHE_OPENSHIFT_PROJECT}.$(minishift ip).nip.io` for minishift, `${CHE_OPENSHIFT_PROJECT}.8a09.starter-us-east-2.openshiftapps.com` for osio)

OCP and Minishift only options:

* `OPENSHIFT_USERNAME`: username to login on the OpenShift cluster. Ignored if `OPENSHIFT_TOKEN` is set (default is `developer`)
* `OPENSHIFT_PASSWORD`: password to login on the OpenShift cluster. Ignored if `OPENSHIFT_TOKEN` is set (default is `developer`)

# Custom Che Workspace Runtimes in OpenShift

Defining a custom Runtime Stack using [a recipe]({{base}}{{site.links["devops-runtime-recipes"]}}), as a Dockerfile or a Docker Compose file, is currently not supported on OpenShift.

However it is still possible to define new Runtime Stacks using Docker images that have been pushed to a Docker registry. Instructions to create a custom Runtime Stack can be found [here]({{base}}{{site.links["devops-runtime-stacks"]}}).

Custom Docker images must meet [the normal criteria]({{base}}{{site.links["devops-runtime-recipes"]}}#che-runtime-required-dependencies) required to run as a Che runtime. In addition it should follow the [guidelines to create Docker images to run on OpenShift](https://docs.openshift.org/latest/creating_images/guidelines.html#openshift-origin-specific-guidelines).

Some examples of Dockerfiles used to create such images can be found [here](https://github.com/redhat-developer/che-dockerfiles/tree/master/recipes).
