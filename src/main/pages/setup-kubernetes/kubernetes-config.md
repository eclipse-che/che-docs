---
title: "Configuration: Kuberentes"
keywords: kubernetes, configuration
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: kubernetes-config.html
folder: setup-kubernetes
---

## How It Works

Che server behavior can be configured by passing environment variables to Che deployment.

There are multiple ways to edit Che deployment to add new or edit existing envs:

* `kubectl edit dc/che` opens Che deployment yaml in nano editor (VIM is used by default)
* manually in Kubernetes web console > deployments > Che > Edit
* `kubectl set env dc/che KEY=VALUE KEY1=VALUE1` updates Che deployment with new envs or modifies values of existing ones

## What Can Be Configured?

You can find deployment env or config map in yaml files. However, they do not reference a complete list of environment variables that Che server will respect.

Here is a [complete](https://github.com/eclipse/che/tree/master/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che) list of all properties that are configurable for Che server.

You can manually convert properties into envs, just make sure to follow [instructions on properties page](properties.html#properties-and-environment-variables)

## Admin Guide

Find more information on most critical configuration options at [Kubernetes admin guide][kubernetes-admin-guide]

## Che Workspace Unrecoverable Events

By default, if one of the following Kubernetes / OpenShift events (`Failed Mount` / `Failed Scheduling` / `Failed`) occurs during a startup, workspace will be immediately terminated before timeout.
For changing or disabling (via a blank value) default unrecoverable events the following environment variable should be used:

`CHE_INFRA_KUBERNETES_WORKSPACE_UNRECOVERABLE_EVENTS`

{% include links.html %}
