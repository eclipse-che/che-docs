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
You can use the terminal and command line to install additional libraries and tools. After you have created a workspace, open a terminal in the IDE.  You can then perform commands like `npm` or `yum install` to add software into your workspace.  These changes will only exist for the lifespan of this single workspace. You can capture these changes permanently by writing a custom stack that includes these commands in a Dockerfile (this method will make your workspace shareable with others).

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

### Dashboard Machine Information
Information on each machine can be viewed in the `Dashboard`. Information on each machine in a workspace can be viewed after clicking on the workspace name and selecting the `Machines` tab. Machine information includes project sources, RAM, [agents]({{base}}{{site.links["devops-ws-agents"]}}), exposed ports, and environment variables (found on the `Agents`, `Servers`, `Env Variables` tabs). All of these configuration items can be changed on a stopped workspace/machine. If the workspace/machine is running, the workspace will be stopped automatically then restarted after the configuration is saved. Changes made to the runtime configuration will only affect the workspace and will not be saved to the original stack so won't affect other workspaces made from that stack.

![Che-machine-information-edit.jpg]({{base}}{{site.links["Che-machine-information-edit.jpg"]}})
