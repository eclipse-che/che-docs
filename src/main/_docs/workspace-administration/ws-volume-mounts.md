---
tags: [ "eclipse" , "che" ]
title: Volume Mounts
excerpt: ""
layout: docs
permalink: /:categories/volume-mounts/
---
{% include base.html %}

Volume mounts are used by Eclipse Che to mount remote external files and directories into the workspaces and containers within them.

# Mounting Volumes
Mounting volumes makes them available to all your workspaces. You can mount one or more volumes by uncommenting the `CHE_WORKSPACE_VOLUME` environment variable in the `che.env` file (found in the root of the data directory you mounted into Che when starting it) and adding your directories or files to it. Add multiple entries separated by semicolons to mount multiple volumes.

In the `che.env`:

```shell  
# Example of a single mount
CHE_WORKSPACE_VOLUME=/codenvy/tmp:/home/user/tmp

# Example of multiple mounts
CHE_WORKSPACE_VOLUME=/codenvy/tmp:/home/user/tmp;/.ssh:/home/user/.ssh
```

# Setting Permissions  
Set read-only or read-write permissions to volumes by adding `:ro`(read-only) or `:rw`(read-write) to the end of the mount definition(s). When no permission is set Che assumes a read-write permission.

In the `che.env`:

```shell  
CHE_WORKSPACE_VOLUME=~/.ssh:/home/user/.ssh:ro;~/.m2:/home/user/.m2:rw

```
