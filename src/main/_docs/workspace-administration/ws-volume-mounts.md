---
tags: [ "eclipse" , "che" ]
title: Volume Mounts
excerpt: ""
layout: docs
permalink: /:categories/volume-mounts/
---
{% include base.html %}

Volume mounts are used by {{site.product_formal_name}} to mount remote external files and directories into the workspaces and containers within them.

# Mounting Volumes
Mounting volumes makes them available to all your workspaces. You can mount one or more volumes by uncommenting the `{{site.data.env["WORKSPACE_VOLUME"]}}` environment variable in the `{{site.data.env["filename"]}}` file (found in the root of the data directory you mounted into {{site.product_mini_name}} when starting it) and adding your directories or files to it. Add multiple entries separated by semicolons to mount multiple volumes.

In the `{{site.data.env["filename"]}}`:

```shell  
# Example of a single mount
{{site.data.env["WORKSPACE_VOLUME"]}}=/codenvy/tmp:/home/user/tmp

# Example of multiple mounts
{{site.data.env["WORKSPACE_VOLUME"]}}=/codenvy/tmp:/home/user/tmp;/.ssh:/home/user/.ssh
```

# Setting Permissions  
Set read-only or read-write permissions to volumes by adding `:ro`(read-only) or `:rw`(read-write) to the end of the mount definition(s). When no permission is set {{site.product_mini_name}} assumes a read-write permission.

In the `{{site.data.env["filename"]}}`:

```shell  
{{site.data.env["WORKSPACE_VOLUME"]}}=~/.ssh:/home/user/.ssh:ro;~/.m2:/home/user/.m2:rw
```

# Private Unshared Label Volume

For operating systems like CentOS 7 with SELinux activated volume mounts require volumes to be labelled. Providing a `Z` option creates a private unshared label volume. For other operating system that do not have SELinux the `Z` option does not need to be provided but in all cases will work if provided. More information can be found at [https://docs.docker.com/engine/tutorials/dockervolumes/#/volume-labels](https://docs.docker.com/engine/tutorials/dockervolumes/#/volume-labels) and [http://www.projectatomic.io/blog/2015/06/using-volumes-with-docker-can-cause-problems-with-selinux/](http://www.projectatomic.io/blog/2015/06/using-volumes-with-docker-can-cause-problems-with-selinux/).
