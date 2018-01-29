---
title: "Quick-Start"
keywords: docker, installation, minishift, openshift
tags: [installation, docker]
sidebar: user_sidebar
permalink: quick-start.html
folder: setup
---

{% include links.html %}

## MiniShift

Pre-reqs: Running [MiniShift](https://docs.openshift.org/latest/minishift/getting-started/index.html) instance

```bash
git clone https://github.com/minishift/minishift-addons
minishift addons install <path_to_minishift-addons>/add-ons/che
minishift addons enable che
minishift addons apply \
    --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:nightly \
    --addon-env OPENSHIFT_TOKEN=$(oc whoami -t) \
    che
```

Installation and configuration docs:

[Single][openshift] and [multi User on OpenShift][multi-user-openshift]

[Configuration on OpenShift][openshift-config]

## Docker

Pre-reqs: Docker 17+ installed

```bash
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /local/path:/data eclipse/che start
```

Note that `/local/path` can be any path on your local machine where you want to store Che data and projects.

MacOS users will also need to setup [IP alias](docker.html#pre-requisites).

Installation and configuration docs:

[Single and multi-user on Docker][docker]

[Configuration on Docker][docker-config]

Create and [start your first workspace][creating_starting_workspaces], import a [project][projects], [build and run][commands_ide_macro] your project.
