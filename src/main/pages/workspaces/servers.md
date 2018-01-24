---
title: "Servers"
keywords: workspace, runtime, recipe, docker, stack, servers, server, port, preview, preview url, server
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: servers.html
folder: workspaces
---

{% include links.html %}

## What Are Servers

A server defines protocol and port of a process that runs in a machine. It also has a name and optional attributes, if this is a `special purpose` server, for example a [Language Server][TODO: language_servers]. In simple words, if you need to access a process in your workspace machine, you need to add a server. You can do it in User Dashboard or by editing workspace machine config:

```json
"node": {
    "attributes": {},
    "port": "3000",
    "protocol": "http"
    }
```

{% include image.html file="workspaces/servers_dashboard.png" %}

If your workspace is running, saving a new server will restart a workspace.

## Preview URLs

Just adding a server with port 3000 does not mean you can use this port to access a server. Each server is assigned with a URL in the runtime, i.e. when a workspace is running. In case of Docker, port 3000 will be published to a random port from the ephemeral port range (32768-65535). In case of OpenShift, a route bound to a service is created. Routes are **persistent URLS**, while server URLS provided in a Docker implementation of Che **change** every time your start a workspace.

## What Is My Preview?

Say, you have added a server with port 3000 and started a workspace. There are multiple ways to get its preview URL:

* Using a [macro][commands_ide_macro] in a command
* In the IDE, `+` icon in the bottom panel under the editor
{% include image.html file="workspaces/servers.png" %}
* In User Dashboard, **Workspaces > YourWorkspace > Servers** tab

You will also see URLS of some of the internal servers - agents that server launches when the workspace container/pod is up.
