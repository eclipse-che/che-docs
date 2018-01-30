---
title: "Chedir Up and Down"
keywords: chedir, factories
tags: [chedir, factories]
sidebar: user_sidebar
permalink: chedir-up-and-down.html
folder: workspace-automation
---

{% include links.html %}

In the first version of Chedir, each Chedir directory maps to a single Che server containing a single workspace. That workspace can have multiple projects and source repositories that are part of it.

You can boot both a Che server and a workspace (with its embedded runtimes) with a single command:

```shell  
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock
                    -v <path>:/data
                    -v <path-to-project>:/chedir
                       eclipse/che:<version> dir up

```

This command will boot a Che server according to the properties in the Chefile. If necessary, the right Che launcher and Che server Docker images will be downloaded and cached. After the server has booted, Chedir will create a workspace and start its runtime, also as a set of Docker containers.

If there is an existing Che server running with the configuration specified, Chedir will discontinue and recommend that you create a different configuration to avoid conflicts.

When the process of creation has completed, you will be presented with two URLs:  

1: Che server URL - a URL that will open the dashboard to manage the Che instance  
2: Workspace URL - a URL that will open the browser IDE with the workspace configured  

The workspace is a fully functional runtime environment. You can work within the workspace, SSH into it, and also work on code. Any code changes will be synchronized with the local directory. You can also perform git operations such as add, commit, and push from within the IDE.


Run Chedir `down` command on the host machine. Chedir will stop the workspace runtime, stop the Che server, and return to the host. The workspace and its project will be preserved.  You can run Chedir `up` to reactivate it. This command is the equivalent of running `docker run -it --rm <DOCKER_PARAMETERS> eclipse/che:<version> stop` with the CLI.

To stop the Che server and remove the workspace, you can destroy it.

```shell  
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock
                    -v <path>:/data
                    -v <path-to-project>:/chedir
                       eclipse/che:<version> dir destroy
```

**NEXT STEPS**

[Author a custom Chefile][chefile] to tailor how the workspace is created and adapted to your project.
