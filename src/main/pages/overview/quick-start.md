---
title: "Quick-Start"
keywords: docker, installation, minishift, openshift
tags: [installation, docker]
sidebar: user_sidebar
permalink: quick-start.html
folder: overview
---

{% include links.html %}

Eclipse Che is a developer workspace server and cloud IDE. You install, run, and manage Eclipse Che with with different container orchestration engine such as Docker or OpenShift.

Eclipse Che is available in two modes:
- **Single-user**: This is suited for personal desktop environments.
- **Multi-user**: This is an advanced setup for Che and is for organizations and developer teams.

See [Single and Multi-User][single-multi-user] to learn more. The quick starts are for 'single-user' mode. 

## Docker

**Prerequisites**
- Ensure that the lastest Docker version is installed (Docker 17+)
- Ensure that you create an IP alias if macOS.
  In a terminal, run the `sudo ifconfig la0 alias $IP` command. `$IP`is found either in **Preferences> Advanced > Docker subnet** or run the `docker run --rm --net host eclipse/che-ip:nightly`.

**Procedure**

To run Che in single mode, enter this command:

```bash
$ docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /local/path:/data eclipse/che start
```

Note that `/local/path` can be any path on your local machine where you want to store Che data and projects.

**Next Steps**

Create and [start your first workspace][creating-starting-workspaces], import a [project][ide-projects], [build and run][commands-ide-macro] your project.

**Additional Resources**

- [Single-user on Docker][docker-single-user]
- [Multi-user on Docker][docker-multi-user]
- [Configuration on Docker][docker-config]
- [Che CLI for Docker][docker-cli]


## OpenShift

**Prerequisities**
- Ensure that you are using the latest version of [MiniShift](https://docs.openshift.org/latest/minishift/getting-started/index.html). See [MiniShift add-on for Che](https://github.com/minishift/minishift-addons/tree/master/add-ons/che).


**Procedure**

To run Che in single mode, take these steps:

```bash
$ git clone https://github.com/minishift/minishift-addons
$ minishift addons install <path_to_minishift-addons-clone>/add-ons/che
$ minishift addons enable che
$ minishift addons apply \
    --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:nightly \
    --addon-env OPENSHIFT_TOKEN=$(oc whoami -t) \
    che
```

**Next Steps**

Create and [start your first workspace][creating-starting-workspaces], import a [project][ide-projects], [build and run][commands-ide-macro] your project.

**Additional Resources**

- [Single-user on OpenShift][openshift-single-user]
- [Multi-user on OpenShift][openshift-multi-user]
- [Configuration on OpenShift][openshift-config]

You can see more information on the Openshift flavors supported by Che:
- [OpenShift Container Platform (OCP)](https://www.openshift.com/container-platform/index.html): OpenShift on-premise, that you can install in your Data Center.
- [OpenShift Online (OSO)](https://www.openshift.com/features/index.html): On-Demand OpenShift hosted on public cloud and managed by Red Hat.
- [OpenShift Dedicated (OCD)](https://access.redhat.com/products/openshift-dedicated-red-hat/): Enterprise public cloud with your own OpenShift cluster managed by Red Hat.
- [MiniShift](https://www.openshift.org/minishift/): OpenShift running on your local environment.







