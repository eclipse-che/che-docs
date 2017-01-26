---
tags: [ "eclipse" , "che" ]
title: Setup&#58 Proxies
excerpt: "Setting up the ARTIK IDE behind a proxy."
layout: artik
permalink: /:categories/proxies/
---
{% include base.html %}

(Note that the ARTIK IDE is based on the open source Eclipse Che project - you will see references to Che in these docs).

You can install and operate ARTIK behind a proxy:

1. Configure each physical node's Docker daemon with proxy access.
2. Optionally, override workspace proxy settings for users if you want to restrict their Internet access.

Before starting ARTIK, configure [Docker's daemon for proxy access](https://docs.docker.com/engine/admin/systemd/#/http-proxy). If you have Docker for Windows or Docker for Mac installed on your desktop and installing Che, these utilities have a GUI in their settings which let you set the proxy settings directly: [Windows](https://docs.docker.com/docker-for-windows/#/proxies) | [Mac OSX](https://docs.docker.com/docker-for-mac/#/http-proxy-settings).

Please be mindful that your `HTTP_PROXY` and/or `HTTPS_PROXY` that you set in the Docker daemon must have a protocol and port number. Proxy configuration is quite finnicky, so please ensure you provide a fully qualified proxy location.

If you configure `HTTP_PROXY` or `HTTPS_PROXY` in your Docker daemon, we will add `localhost,127.0.0.1,CHE_HOST` to your `NO_PROXY` value where `CHE_HOST` is the DNS or IP address of your ARTIK instance. We recommend that you add the short and long form DNS entry to your Docker's `NO_PROXY` setting if it is not already set.

We will add some values to `artik.env` that contain some proxy overrides. You can optionally modify these with overrides:

```
CHE_HTTP_PROXY=<YOUR_PROXY_FROM_DOCKER>
CHE_HTTPS_PROXY=<YOUR_PROXY_FROM_DOCKER>
CHE_NO_PROXY=localhost,127.0.0.1,<YOUR_CHE_HOST>
CHE_HTTP_PROXY_FOR_WORKSPACES=<YOUR_PROXY_FROM_DOCKER>
CHE_HTTPS_PROXY_FOR_WORKSPACES=<YOUR_PROXY_FROM_DOCKER>
CHE_NO_PROXY_FOR_WORKSPACES=localhost,127.0.0.1,<YOUR_CHE_HOST>
```

The last three entries are injected into workspaces created by your users. This gives your users access to the Internet from within their workspaces. You can comment out these entries to disable access. However, if that access is turned off, then the default templates with source code will fail to be created in workspaces as those projects are cloned from GitHub.com. Your workspaces are still functional, we just prevent the template cloning.
