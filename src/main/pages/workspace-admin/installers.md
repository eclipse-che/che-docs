---
title: "Installers"
keywords: workspace, runtime, recipe, docker, stack, installers, agents
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: installers.html
folder: workspace-admin
---

{% include links.html %}

## What Are Installers?

Installers are scripts that are injected into machines in a runtime and get executed there to:

1. Prepare environment and download dependencies for particular software or tool
2. Install chosen software and dependencies
3. Launch software and tools in a certain way (arguments, mode etc) that provide extra functionality for a workspace

Installers are typically language servers and tools that provide features like ssh access to a workspace machine etc. You can find a complete list of available installers in workspace details, Installers tab.

```
"installers": [
    "org.eclipse.che.exec",
    "org.eclipse.che.terminal",
    "org.eclipse.che.ws-agent",
    "org.eclipse.che.ssh"
        ]
```

## How Installers Work?

Installers scripts are saved into a configuration file that a [bootstrapper](what-are-workspaces.html#bootstrapper) uses to execute its jobs. An installer script is a shell script that works exactly the same way it'd work in your local Linux environment. Che server then checks if the process that an installer has launched is alive.

There are installers that activate special agents like workspace agent, terminal and exec agent. For example, if a workspace agent fails to start, the workspace will be considered as started but the IDE won't be usable. Exec agent failure will result in unavailability of commands widget.

## Enable and Disable Installers

Installers are can be enabled/disabled in User Dashboard per machine, or directly in workspace machine configuration. When an installer is enabled, bootstrapper executes an installer script after the workspace has started.

{% include image.html file="workspaces/installers.png" %}

## Installers Failures

As installer scripts may expect that a user in the container/pod is in `sudoers` .e. have privileges, some of them may fail due to `permission denied` issues. This is the case with OpenShift, where a pod is run by an arbitrary user with no permissions to use sudo, and/or access/modify resources on the file system. In most cases, though, this problem can be solved by rebuilding the base image so that it already has all of the dependencies for a particular agents that an installer activates. Another possible issue might be with permissions to files and folders. For example, an installer may need to write to [user home directory](https://github.com/eclipse/che-dockerfiles/blob/master/recipes/stack-base/centos/Dockerfile#L45-L57).
