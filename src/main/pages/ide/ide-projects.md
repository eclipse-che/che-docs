---
title: "Projects and Project Import"
keywords: workspace, runtime, project, projects
tags: [workspace, runtime]
sidebar: user_sidebar
permalink: ide-projects.html
folder: ide
---

{% include links.html %}

## Default Location of Projects

When a workspace machine with a workspace agent starts, the IDE makes calls to Project API to get workspace projects. By default, they are located in `projects` in a machine container/pod. This location isn't configurable as many other IDE components depend on it.

Projects are displayed in the Project Tree on the left. You can also see them in the terminal - `ls -la /projects`. When a workspace is stopped, its machines are terminated, however, `/projects` gets mounted onto the host file System (either data volume or PVC), so when a new container/pod is started, your workspace projects are always there.

{% include image.html file="ide/project_tree.png" %}

## File Watchers

Since changes to project source files may not be originated from IDE editor only, there are file watchers listening to changes on the file system. Thus, if you create, edit or delete resources on your file system using terminal or REST API, changes will be propagated to project tree and editor. File watchers are disabled in certain situations, like project import, to avoid flooding events.

## Project Import and SSH Connection

There are multiple ways to import a project:

1. Add a project to [workspace configuration][projects] in User Dashboard. Once workspace configuration is saved, and the workspace is being opened, the IDE will grab workspace config, and if there are projects associated with it, they will be automatically imported. If these projects can be found on a file system, the IDE skips this step.

2. Import a project into a running workspace. This can be done in the IDE, Workspace > Import project menu. If you need to import a private project, [setup SSH keys][version_control].

{% include image.html file="ide/import_project.png" %}
