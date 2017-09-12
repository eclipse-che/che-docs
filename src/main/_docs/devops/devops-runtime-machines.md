---
tags: [ "eclipse" , "che" ]
title: Runtime Machines
excerpt: ""
layout: docs
permalink: /:categories/runtime-machines/
---
{% include base.html %}

A machine is part of an environment, which are in turn part of a {{site.product_mini_name}} workspace. The [workspace administration introduction]({{base}}{{site.links["devops-intro"]}}) explains the details of this relationship.

A machine is created from a [runtime stack]({{base}}{{site.links["devops-runtime-stacks"]}}). {{site.product_mini_name}} supports both single-machine environments and multi-machine environments. The {{site.product_mini_name}}  server manages the lifecycle of environments and the machines inside, including creating snapshots of machines.  Additionally, the {{site.product_mini_name}}  server can inject [workspace agents]({{base}}{{site.links["devops-ws-agents"]}}) into a machine to provide additional capabilities inside the machine.

## Add / Remove Libraries and Tools To Runtime Machines
You can use the terminal and command line to install additional libraries and tools. After you have created a workspace, open a terminal in the IDE.  You can then perform commands like `npm` or `yum install` to add software into your workspace.  These changes will only exist for the lifespan of this single workspace. You can capture these changes permanently by creating a snapshot (which can then be used as a [recipe]({{base}}{{site.links["devops-runtime-recipes"]}})), or writing a custom stack that includes these commands in a Dockerfile (this method will make your workspace shareable with others).

![install-jetty8.png]({{base}}{{site.links["install-jetty8.png"]}})

The following example takes a Java ready-to-go stack and adds Jetty8 in the workspace runtime configuration.

```shell  
# apt-get update
sudo apt-get update

# Upgrade existing tools
sudo apt-get upgrade

# Install Jett8
sudo apt-get install jetty8

# Jetty8 installed at path /usr/share/jetty8
```

## Machine Snapshot
Machines can have their internal state saved into a Docker image with a snapshot.

Snapshots are important to preserve the internal state of a machine that is not defined by the recipe. For example, you may define a recipe that includes maven, but your project may require numerous dependencies that are downloaded and locally installed into the internal maven repository of the machine. If you stop and restart the machine without a snapshot, that internal state will be lost.

Note that once you've snapshotted a workspace, changing the environment or machine names inside the workspace will result in the snapshot being lost.

Snapshots image a machine and then commit, tag, and optionally push that image into a Docker registry. By default machines are automatically snapshotted when they are stopped.

**Note that snapshots do not include the contents of the machine's `tmp` folder.**

By default, {{site.product_mini_name}} does not need a local/remote Docker registry to create snapshots. However, you can [configure]({{base}}{{site.links["setup-configuration"]}}) a local or remote Docker registry to use for snapshots.

If no registry is used, a container is committed into an image which is then tagged, so that next time a workspace is started with this image. The behavior is regulated with the following environment variables:

```shell  
# Provide in {{site.data.env["filename"]}}

# If false, snaps are saved to disk. If true, snaps are saved in a registry.
# The namespace is how the snapshots will be organized in the registry.
{{site.data.env["DOCKER_REGISTRY__FOR__SNAPSHOTS"]}}=false
{{site.data.env["DOCKER_NAMESPACE"]}}=NULL

# Docker Registry for Workspace Snapshots
{{site.data.env["DOCKER_REGISTRY"]}}=<your_private_registry_url>:5000

# Enable/Disable auto snapshotting and auto restoring from a snapshot
{{site.data.env["WORKSPACE_AUTO__SNAPSHOT"]}}=true
{{site.data.env["WORKSPACE_AUTO__RESTORE"]}}=true
```
 See our other docs [for details on setting up a local or remote Docker Registry]({{base}}{{site.links["setup-configuration"]}}).


### Dashboard Machine Information
Information on each machine can be viewed in the `Dashboard`. Information on each machine in a workspace can be viewed after clicking on the workspace name and selecting the `Machines` tab. Machine information includes project sources, RAM, [agents]({{base}}{{site.links["devops-ws-agents"]}}), exposed ports, and environment variables (found on the `Agents`, `Servers`, `Env Variables` tabs). All of these configuration items can be changed on a stopped workspace/machine. If the workspace/machine is running, the workspace will be stopped automatically then restarted after the configuration is saved. Changes made to the runtime configuration will only affect the workspace and will not be saved to the original stack so won't affect other workspaces made from that stack.

![Che-machine-information-edit.jpg]({{base}}{{site.links["Che-machine-information-edit.jpg"]}})
