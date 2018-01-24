---
title: "Che As a Framework"
keywords: framework, overview, plugin, extension, language support, language server
tags: [extensions, assembly]
sidebar: user_sidebar
permalink: framework_overview.html
folder: framework
---

{% include links.html %}


## Che as a Product

Eclipse Che is available as a default build, i.e. something that is released and shipped on a regular basis. The regular build of Che contains almost all available plugins and comes with default configuration and settings. You can use Che as a standalone product on [Docker][docker] and [OpenShift][openshift].

## Che as a Framework

Eclipse Che is a platform that can be customized by:

* adding client side plugins that bring new menus, panels and other UI components, [authored in GWT][ide-extensions-gwt]
* adding client side plugins authored in [JavaScript/TypeScript][ide-extensions-js] (or any other JS frameworks)
* adding [server side components and agents][server-side-extensions] that get deployed to a workspace machines
* adding support of [new infrastructure][spi_overview]
* deploying custom [workspace master components][che_master]
* enable language tooling via [Language Servers][language_servers]

On top of that Eclipse Che can be integrated into other platforms since it exposes [REST APIs][rest_api] for all server side components which makes it possible to create on demand workspaces serving needs of CI, support, issue tracking and other systems.
