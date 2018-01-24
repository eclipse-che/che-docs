---
title: "Docker vs OpenShift Deployment"
keywords: docker, oepsnhift
tags: [installation, docker, openshift]
sidebar: user_sidebar
permalink: docker_openshift.html
folder: setup
---

## Comparison Table

|  Feature                 | **Docker**   | **OpenShift**                                                                              |
| root access              | yes          | no (See: [Configuration](openshift-config.html#enable-ssh-and-sudo))                       |
| https                    | no           | yes (See: [Configuration](openshift-config.html#https-mode))                               |
| scalability              | no           | yes (See: [Configuration](openshift-config.html#scalability))                              |
| priviliged containers    | yes          | no (configurable in [OpenShift](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_scc.html#grant-access-to-the-privileged-scc))         |
| health checks            | no           | yes                                                                                        |
| persistent preview URLs  | no           | yes                                                                                        |
| installers               | yes          | some installers may require [sudo access](openshift-config.html#enable-ssh-and-sudo)       |
| file system permissions  | not limited  | limited to directories owned by root [group](openshift-config.html#filesystem-permissions) |


## Running Che on Docker

Che on Docker isn't scalable, i.e. one cannot add more nodes to run workspaces. Of course, it is possible to use a fairly large instance with 8+ CPUs and 32+ RAM, however at some point a great number of running containers (with heavy processes running in them) can make the node unresponsive. This will both affect workspace master and all running workspaces. At the same time, Che on Docker is flexible and easily configurable for an ordinary user.

**Root Access**

With Che on Docker, users can have root access in workspace containers. This means you can run system services and install software in runtime.

**SSH Access**

By default, `sshd` starts in all ready-to-go stack images. You can connect to a remote workspace using ssh keys or username/password (available in custom stacks only) or sync workspace project files to a local machine.

**Privileged Containers**

Che on Docker allows workspace containers to be running in a [privileged mode](docker-config.html#privileged-mode).

Though deploying administering Che on Docker may seem a little bit easier than doing it in OpenShift, it's OpenShift that unleashes the power of Eclipse Che as a workspace server and cloud IDE.

**[Install Single-User Che on Docker][docker]**

**[Install Multi-User Che on Docker][multi-user-docker]**

## Deploying to OpenShift

When deployed to OpenShift, Che provides the following features that are not available in Che on Docker:

**Scalability**

Che talks to OpenShift API to create workspace pods, and it is OpenShift that schedules them to available nodes. OpenShift cluster admin can add and remove nodes (or label them as those that are not ready to run pods) depending on demand for running Che workspaces.

**HTTPS support**

HAProxy that runs in an OpenShift cluster takes care of creating secure routes, thus HTTPS support is provided by OpenShift itself.

**Persistent Preview URLs**

To access running applications and processes in Che workspaces, Che creates services and routes that are persistent URLs.

**Health Checks**

OpenShift restarts failed deployments and offers health checks for pods. This can significantly minimize the effect of infrastructure outages.

**[Deploy Single User Che to OpenShift][openshift]**

**[Deploy Multi-User Che to OpenShift][multi-user-openshift]**

{% include links.html %}
