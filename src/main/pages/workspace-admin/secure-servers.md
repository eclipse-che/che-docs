---
title: "Secure Servers"
keywords: workspace, runtime, recipe, kubernetes, openshift, stack, servers, server, secure server
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: secure-servers.html
folder: workspace-admin
---

Now that you have made yourself familiar with [secure servers](servers.html#secure-server) concept, let’s take a closer look at enabling this functionality and implementation details.

## How to enable secure servers functionality?

This functionality is in **beta** phase now and it is disabled by default.
It is needed to set `CHE_SERVER_SECURE__EXPOSER=jwtproxy` environment variable of Che Server to enable secure servers with JwtProxy as proxy backend.
Note that it is supported by Kubernetes and OpenShift infrastructures but not Docker.

## How to access to secure server

To request secure server it is needed to provide machine token. Machine token may be fetched from workspace runtime.

There are three possible ways to specify token in the request to secure server, ways are ordered in priority of search:
- specify token in `access_token` cookie. This option can be configured and is disabled by default.
- specify token in `Authorization` request header. Note that `Bearer` prefix should be specified as token type;
- specify it in `token` query parameter. This way is not recommended to be used since token will be present in URL. But there can be limited cases when it’s not possible to use `Authorization` header or cookies. An example of such exceptional case can be: OAuth authentification initialization.



## Cookies Authentication
Authentication with cookies increases the probability of CSRF attack and because of that it is disabled by default for servers.
Authentication with cookies may be enabled via `cookiesAuthEnabled` server configuration attribute.
CSRF is not actual if server doesn't have any methods that processes modifying GET, POST requests and accepts html form supported content types. Otherwise server should implements additional protection from CSRF attack by itself if cookies authentication is needed.

Authentication with cookies is the most useful for a server which is a web application. It solves to issues for it:
- a client initialization issues - no needs to specify token explicitly after storing an token in cookies otherwise token must be specified in URL as query parameter which is not good from security perspective;
- a client doesn't need to specify token explicitly during calls to its server.

An example of such web application is Theia IDE that loads main page from secure server with token specified in cookie and the same token is used for further communication between Theia Client Side and Server Side.

## JwtProxy

Now [JwtProxy](https://github.com/eclipse/che-jwtproxy) is the only supported backend for secure servers. It proxies all requests to secure servers an verify incoming requests.

To make cookies authentication easier JwtProxy has authentication endpoint that may be used for automatically putting machine token into cookies. The following diagram shows how it works

{% include image.html file="diagrams/servers-cookies-auth.svg" %}
