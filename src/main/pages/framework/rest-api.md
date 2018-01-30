---
title: "REST API"
keywords: framework, overview, master, server, REST API
tags: [extensions, dev-docs, assembly]
sidebar: user_sidebar
permalink: rest-api.html
folder: framework
---

{% include links.html %}

Eclipse Che server side components - both for master and workspace agents - are exposed as REST services which makes it easy to integrate Che in other platforms or use custom clients to create and run workspaces, import and update projects, update/delete workspaces and associated objects etc.

You can make yourself familiar with available APIs in Swagger UI page - all methods have swagger annotations. Che master APIs are available at at `${CHE_HOST}/swagger`. If you use multi-user Che flavor, you will need [authentication token][authentication].

Probably, [workspace API](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-workspace/src/main/java/org/eclipse/che/api/workspace/server/WorkspaceService.java) is the most interesting one to take a closer look. Workspace API lets you remotely interact with Che master to create developer environments - create, update and delete workspaces, start workspaces by creating and deleting runtime, add, update and delete workspace environments, associate commands with a workspace.

Workspace agent APIs focus on [project types][project-types], [projects][projects] and things related to projects, like [Git][version-control]. To see the list of available workspace REST APIs, follow instructions in [authentication docs][authentication]. With [Project API](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project/src/main/java/org/eclipse/che/api/project/server/ProjectService.java) you can programmatically create/import projects in a workspace, update configuration, get file content using custom plugins or 3rd-party clients.
