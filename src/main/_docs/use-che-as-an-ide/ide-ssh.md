---
tags: [ "eclipse" , "che" ]
title: SSH
excerpt: "Connect to your workspaces using SSH"
layout: docs
permalink: /:categories/ssh/
---
{% include base.html %}
Workspaces are configured with an SSH [agent]({{base}}{{site.links["ws-agents"]}}#adding-agents-to-a-machine), which runs an SSH daemon within your workspace runtime. You can connect to your workspace on the command line and get root access to the runtime (similar to what the Web terminal provides) from other machines. You can optionally disable the SSH agent for your workspace from within the dashboard.

# Public / Private Key Generation
If your workspace has the SSH [agent]({{base}}{{site.links["ws-agents"]}}#adding-agents-to-a-machine) activated in the [dashboard]({{base}}{{site.links["ws-machines"]}}#dashboard-machine-information), then {{ site.product_mini_name }} runs an SSH daemon within the machines that are part of your workspace. The SSH agent is activated by default with all new workspaces and you can manually disable it within the dashboard. If your workspace is powered by Docker Compose, then the SSH agent is deployed into every container that makes up your compose services. You can optionally remove the SSH [agent]({{base}}{{site.links["ws-agents"]}}#adding-agents-to-a-machine) from selected machines of your compose services from within the [dashboard]({{base}}{{site.links["ws-machines"]}}#dashboard-machine-information).

Each new workspace has a default key-pair generated for it. The private key is inserted into each machine of a workspace and they will all share the same public key. You can generate a new key-pair in the dashboard, or remove the default one to be replaced with yours.
![ssh-delete-create-keypair.gif]({{base}}{{site.links["ssh-delete-create-keypair.gif"]}})

{% if site.product_mini_cli=="codenvy" %}API clients must be authenticated with appropriate permissions before they can request the private key for a workspace.
{% else %}Eclipse Che does not have any user authentication, so any client can connect to the {{site.product_mini_name}} server REST API and then request the private key for the workspace. In Codenvy, API clients must be authenticated with appropriate permissions before they can request the public key for a workspace.{% endif %}

We provide an optional ssh client built into [cli](#connect) for connecting to a workspace using SSH.

# List Workspaces  
You can get a list of workspaces in a {{site.product_mini_name}} server that have an SSH agent deployed. These are the workspaces that you can SSH into.

```shell  {% assign action="list-workspaces"%}
$ docker run -ti <volume-mounts> {% if site.product_mini_cli=="codenvy" %}codenvy/cli action {{action}} [parameters]{% else %}eclipse/che action {{action}} [parameters]{% endif %} 

NAME                      ID                         STATUS
wksp-v4l8(No Sync Agent)  workspaceolhvwg1bjuepyfar  RUNNING

# Parameters
    --url <url>           # {{ site.product_mini_name }} host where workspaces are running
{% if site.product_mini_cli=="codenvy" %}    --user <login email>        # Codenvy user name
    --password <login password> # Codenvy password{% endif %}
```

# Connect  
You can connect to your workspace using our Docker CLI container or your off-the-shelf SSH client such as `ssh` on Linux/Mac or `putty` on Windows.

One nice aspect of our SSH capabilities is that they are all done inside of a Docker container, letting any OS connect to a Che workspace using the same sytnax without the user having to install specialized tools for each OS.

### SSH With CLI

```shell    {% assign action="ssh"%}
# Connect to the machine in a workspace that is designated as the dev machine.
# Each workspace always has one machine that is a dev machine with a dev agent on it.
$ docker run -ti <volume-mounts> {% if site.product_mini_cli=="codenvy" %}codenvy/cli action {{action}} <workspace> [machine-name] [parameters]{% else %}eclipse/che action {{action}} <workspace> [machine-name] [parameters]{% endif %} 

# Arguments
    workspace             # Workspace name or id.  
    machine-name          # Connect to a secondary machine in the workspace(docker compose)
# Parameters
    --url <url>           # {{ site.product_mini_name }} host where workspaces are running
{% if site.product_mini_cli=="codenvy" %}    --user <login email>        # Codenvy user name
    --password <login password> # Codenvy password{% endif %}
```

### SSH With Native Tools
If you want to use your native SSH tools to connect to a workspace, you can get the connectivity information that you need to use through the dashboard as described in [Public/Private Key Generation](#public--private-key-generation) section on this page or using CLI described below. You can then pass this information into `ssh` or `putty` to make a direct connection.

```shell  {% assign action="get-ssh-data"%}
# Connect to the machine in a workspace that is designated as the dev machine.
# Each workspace always has one machine that is a dev machine with a dev agent on it.
$ docker run -ti <volume-mounts> {% if site.product_mini_cli=="codenvy" %}codenvy/cli action {{action}} <ws-name> {% else %}eclipse/che action {{action}} <workspace> [machine-name] [parameters]{% endif %}
SSH_IP=192.168.65.2
SSH_PORT=32900
SSH_USER=user
SSH_PRIVATE_KEY='
-----BEGIN RSA PRIVATE KEY-----
ws-private-key-listed-here
-----END RSA PRIVATE KEY-----
'

# Arguments
    workspace             # Workspace name or id.               
    machine-name          # Connect to a secondary machine in the workspace(docker compose)
# Parameters
    --url <url>           # {{ site.product_mini_name }} host where workspaces are running
{% if site.product_mini_cli=="codenvy" %}    --user <login email>        # Codenvy user name
    --password <login password> # Codenvy password{% endif %}
```
