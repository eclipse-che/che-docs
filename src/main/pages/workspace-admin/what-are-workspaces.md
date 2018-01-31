---
title: "What Is a Che Workspace?"
keywords: workspace, runtime, recipe, docker, yaml, Dockerfile, docker, kubernetes, container, pod
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: what-are-workspaces.html
folder: workspace-admin
---

## Workspace

Eclipse Che reinvents the definition of a workspace which is usually termed as a local directory with projects and some meta-information that IDE uses to properly configure them. In Eclipse Che, a workspace is the developer environment itself represented by Docker containers, k8s pods or something else (for example, a VM, localhost etc), coupled with data persistence mechanism, provision of environment variables, projects and commands which are associated with them, as well as resources allocation attributes.

## Environment

Workspace runtime environment is a set of machines where each machine is defined by a recipe. Environment is considered to be healthy when all machines have successfully started and associated installers executed their jobs. Environment is defined by a recipe that can have different types. It is up to environment (and underlying infra) to validate a recipe.

## Machine

Runtime environment has minimum one machine that can be (at this moment) a Docker container or a Kubernetes pod. You can create multi machine environments with as many machines as your project infrastructure requires. Though each machine has its own configuration and start policy, it is an integral part of environment, and start failures/crashes of one machine may signal about an entire environment being unhealthy. Machines can freely communicate in a common environment using internal network (e.g. by `service:port`).

## Recipe

Workspace environment is defined by a recipe that can be a single Docker image, a Dockerfile, a Docker Compose file, or a Kubernetes list of objects with multiple pods and services.

## Bootstrapper

Inside every machine, a bootstrapper is started. Its role is to start installer scripts that will install chosen software/components into a machine. Bootstrapper is a tiny binary compiled from go code. It starts with a set of parameters and a config file with the list of installer scripts to be executed (see below). Launch of a bootstrapper is the first process executed in a machine after `CMD` or `ENTRYPOINT`.

## Installer

The purpose of an installer is quite straightforward. An installer installs software and services, starts servers, activates agents etc. Some of the servers are crucial to the IDE and workspace in general, such as workspace agent, exec agent and terminal. Others just bring new functionality to a workspace - language servers, SSH installer etc. Bootstrapper executes installer scripts that prepare environment, check for dependencies and install components defined by an installer. You may want to take a look at an [example of an installer script](https://github.com/eclipse/che/blob/che6/agents/ls-csharp/src/main/resources/installers/1.0.1/org.eclipse.che.ls.csharp.script.sh) that prepares environment and installs C# language server.

## Volume

A volume is a mechanism that Eclipse Che uses to persist workspace data. By default, workspace projects are automatically mounted into a host file system, however, a user can define extra volumes for each individual machine in the environment. Implementation of volumes differ depending on the infrastructure (Docker volumes vs Kubernetes PVs and PVCs).

## Environment Variables

An individual set of environment variables is propagated into each individual machine. Depending on the infrastructure, envs are propagated to Docker containers or k8s pods.

## What's Next?

[Create and start your first workspace][creating-starting-workspaces], learn how to define [volumes][volumes] and [env variables][env-variables].

{% include links.html %}
