---
title: What Is Eclipse Che?
keywords: overview
tags: [overview, getting_started]
sidebar: user_sidebar
permalink: index.html
summary: Eclipse Che is a developer workspace framework and cloud IDE

---

## Abstraction

Che defines framework, extension points along with ready-to-use implementation (assembly) for starting and managing isolated and personalized Developer Workspaces in a multi-user, multi-account (though can be assembled as a single-user) environment.

Che Developer Workspace (Workspace) it is a set of integrated resources for convenient:
- Edit source code, manage projects structure and dependencies
- Build, debug, test target application
- Run and deploy target application and development tools on equal to or directly on production runtime environment.

Unlike traditional IDE Che workspace configuration describes not only source code, dependencies and tool meta-information, it also configures environment to start applications. This minimizes divergence between development and production, enabling continuous deployment for maximum agility.

## Key Points
Che has quite complex architecture and big set of components and sub-system.
Here we emphasize the most important aspects of the system and differences from other Development Environments

**Workspaces bring their own Runtimes**

Workspace configuration includes description of Environment for creating Workspace Runtime as a network of computing units (Machines) with source files, Dev tools and other software. So, you can use the same or at least as close as possible development and production environment.

**Portable Workspace**

Each workspace is defined with a JSON data model that contains the definition of its Projects, Environments, IDE that allows a Che server to create replicas. This allows workspaces to move from one location to another, such as from one Che server to another Che server.

**Remote APIs Everywhere**

Both the Che server (master) which starts Workspaces and Workspaces themselves are manageable vis RESTful or JSON-RPC APIs.

**Pluggable Runtime Infrastructures**

Che provides Runtime Infrastructure SPI to make it possible to develop using the same as or even directly production environment with convenience.

**Multi-user and Resources Distribution**

It is supposed that runtime in total may consume a big amount of system resources (CPU, RAM, disk space, network) so multi-User Che also defines interfaces for grouping users and managing limits on per-Account basis (Account can be bound to User or Organization).


## What's Next

You can get started with Che by:
- [Quick-start][quick-start]
- Installing Che for a single user: [Docker][docker] or [OpenShift][openshift]
- Installing a multi-user Che: [Docker][multi-user-docker] or [OpenShift][multi-user-openshift]

{% include links.html %}
