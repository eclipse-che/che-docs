---
title: "Multi-User&#58 Install on Docker"
keywords: openshift, installation
tags: [installation, docker]
sidebar: user_sidebar
permalink: multi-user-docker.html
folder: setup
---

## Run Syntax

```
docker run -it -e CHE_MULTIUSER=true -e CHE_HOST=${EXTERNAL_IP} -v /var/run/docker.sock:/var/run/docker.sock -v ~/.che-multiuser:/data eclipse/che start
```

`~/.che-multiuser` is any local path. This is where Che data and configuration will be stored.

`${EXTERNAL_IP}` should be a public IP accessible to all users who will access the Che instance. You may drop `CHE_HOST` env if you are running Che locally and will access it from within the same network. In this case, Che CLI will attempt to auto-detect your server IP. However, auto-detection may produce erroneous results, especially in case of a complex network setup. If you run Che as a cloud server, i.e. accessible for external users we recommend explicitly providing an external IP for `CHE_HOST`.

## What's Under the Hood

With `CHE_MULTIUSER=true` Che CLI is instructed to generate a special Docker Composefile that will be executed to produce config and run:

* Keycloak container with pre-configured realm and clients
* PostgreSQL container that will store Keycloak and Che data
* Che server container with a special build of multi-user Che assembly

## Deployment Diagram

Multi-user Che on Docker does not differ much from a [multi-user deployment on OpenShift](multi-user-openshift#deployment-diagram) in terms of architecture and communication between services. There are a few differences though:

* containers instead of pods
* volume mounts instead of PVCs
* to need to pre-build Keycloak and Postgres images - configuration is mounted into containers
* port 5050 needs to be publicly available (OpenShift uses route and service)
* Che CLI pre-configures and populates values for envs like CHE_HOST, that is then used in Keycloak configuration files

{% include links.html %}
