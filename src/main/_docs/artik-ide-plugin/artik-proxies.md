---
tags: [ "eclipse" , "che" ]
title: Setup&#58 Proxies
excerpt: "Setting up the ARTIK IDE behind a proxy."
layout: artik
permalink: /:categories/proxies/
---
{% include base.html %}
Your users may need their workspaces to operate over a proxy to the Internet. The ARTIK IDE has three dependencies to the Internet:

1. Docker, in order to download Docker images from DockerHub.
2. Importers, in order to clone sample projects or source code at an external repository to mount into a workspace.
3. Workspaces created by users, which have their own internal operating system. Users that want to reach the Internet from within their workspace, such as for `maven` or `npm`, also need a proxy configuration.

When a user creates a workspace, we will perform docker pull. This command will communicate with Docker Hub. You need to configure proxy settings in Docker:
- [For Docker on Windows 10](https://docs.docker.com/docker-for-windows/#proxies)
- [For Docker on Windows Boot2Docker(Virtualbox)](https://docs.docker.com/engine/admin/systemd/#http-proxy)
- [For Docker on Mac OS](https://docs.docker.com/docker-for-mac/#/http-proxy-settings)
- [For Docker on Linux](https://docs.docker.com/engine/admin/systemd/#http-proxy)

    