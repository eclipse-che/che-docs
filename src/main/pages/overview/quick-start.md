---
title: "Quick-Start"
keywords: docker, installation, minishift, openshift
tags: [installation, docker]
sidebar: user_sidebar
permalink: quick-start.html
folder: setup
---

{% include links.html %}

Eclipse Che is a developer workspace server and cloud IDE. You install, run, and manage Eclipse Che with with different container orchestration engine such as Docker or OpenShift.

Eclipse Che is available in two different modes:
- **Single-user**: perfectly suited for personal desktop environment.
- **Multi-user**: best for organization and developer teams.

Considering the `multi-user` mode as an advanced setup of Eclipe Che, the quick starts are covering only the `single-user` mode. If you are interested by the `multi-user`, please read the following pages:
- [Multi-user configuration on Docker][docker-multi-user]
- [Multi-user configuration on OpenShift][openshift-multi-user]

If you want to learn more about the differences between single-user and multi-user, please [read this page][single-multi-user]


## Docker

On any computer with Docker 17+ installed:

```bash
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /local/path:/data eclipse/che start
```

Note that `/local/path` can be any path on your local machine where you want to store Che data and projects.

MacOS users will also need to setup [IP alias](docker.html#pre-requisites).


Installation and configuration docs:
- [Single-user on Docker][docker-single-user]
- [Multi-user on Docker][docker-multi-user]
- [Configuration on Docker][docker-config]
- [Che CLI for Docker][docker-cli]

Create and [start your first workspace][creating_starting_workspaces], import a [project][ide-projects], [build and run][commands_ide_macro] your project.


## OpenShift

Che supports different flavors of OpenShift:
- **[OpenShift Container Platform (OCP)](https://www.openshift.com/container-platform/index.html)**: OpenShift on-premise, that you can install in your Data Center. 
- **[OpenShift Online (OSO)](https://www.openshift.com/features/index.html)**: On-Demand OpenShift hosted on public cloud and managed by Red Hat.
- **[OpenShift Dedicated (OCD)]([)https://access.redhat.com/products/openshift-dedicated-red-hat/)**: Enterprise public cloud with your own OpenShift cluster managed by Red Hat.
- **[MiniShift](https://www.openshift.org/minishift/)**: OpenShift running on your local environment. 

If you want to try Che on OpenShift, we recommand to you to do it with MiniShift and use the [MiniShift add-on for Che](https://github.com/minishift/minishift-addons/tree/master/add-ons/che). 

On any computer with [MiniShift](https://docs.openshift.org/latest/minishift/getting-started/index.html) running:

```bash
git clone https://github.com/minishift/minishift-addons
minishift addons install <path_to_minishift-addons-clone>/add-ons/che
minishift addons enable che
minishift addons apply \
    --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:nightly \
    --addon-env OPENSHIFT_TOKEN=$(oc whoami -t) \
    che
```

Installation and configuration docs:
- [Single-user on OpenShift][openshift-single-user]
- [Multi-user on OpenShift][openshift-multi-user]
- [Configuration on OpenShift][openshift-config]




