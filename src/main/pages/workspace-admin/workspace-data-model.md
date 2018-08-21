---
title: "Workspace Data Model"
keywords: workspace, runtime, recipe, docker, yaml, Dockerfile, docker, kubernetes, container, pod
tags: [workspace, runtime, docker, kubernetes, dev-docs]
sidebar: user_sidebar
permalink: workspace-data-model.html
folder: workspace-admin
---

{% include links.html %}

```
environments: Map<String, getEnvironments>  // Workspace envs. A workspace can have multiple envs
defaultEnv: STRING                          // A workspace should have a default environment
projects: []                                // Projects associated with a workspace
commands: []                                // Commands associated with a workspace
name: STRING                                // Workspace name that has to be unique in a namespace
links: []                                   //
```

## Environment

{% include image.html file="workspaces/ws_data_model.png" %}


Environment recipe can also have content instead of location, if [recipe][recipes] type is `dockerfile`, `compose` or `openshift`:

```json
"recipe": {
  "type": "compose",
  "content": "services:\n db:\n  image: eclipse/mysql\n  environment:\n   MYSQL_ROOT_PASSWORD: password\n   MYSQL_DATABASE: petclinic\n   MYSQL_USER: petclinic\n   MYSQL_PASSWORD: password\n  mem_limit: 1073741824\n dev-machine:\n  image: eclipse/ubuntu_jdk8\n  mem_limit: 2147483648\n  depends_on:\n    - db",
  "contentType": "application/x-yaml"
}
```

## Projects

{% include image.html file="workspaces/ws_projects.png" %}

Project object structure is quite simple, `source.location` and `source.type` being the most important parameters. There are 2 importer types: `git` and `zip`. New location types can be provided by custom plugins, such as `svn`.

In the example above, a project does not have problems and mixins. If a project is misconfigured or missing sources, it will be marked with a problem (error code and a message explaining the problem).

A mixin adds additional behaviors the project, IDE panels and menus etc. Mixins are reusable across any project type. You define the mixins to add to a project by specifying an array of strings, with each string containing the identifier for the mixin.


| Mixin ID   | Description   
| --- | ---
| `git`   | Initiates the project with a git repository. Adds git menu functionality to the IDE. If a user in the IDE creates a new project and then initializes a git repository, then this mixin is added to that project.   
| `pullrequest`   | Enables pull request workflow where server handles local & remote branching, forking, and pull request issuance. Pull requests generated from within server have another Factory placed into the comments of pull requests that a PR reviewer can consume. Adds contribution panel to the IDE. If this mixin is set, then it uses attribute values for `project.attributes.local_branch` and `project.attributes.contribute_to_branch`.   

The `pullrequest` mixin requires additional configuration from the `attributes` object of the project.  

The `project`object can also include `source.parameters`, which is a map that can contain additional parameters e.g. related to project importer

| Parameter name  | Description   
| --- | ---
| `skipFirstLevel`   | Used for projects with type `zip`. When value is 'true', the first directory inside ZIP will be omitted.       


## Commands

Commands can be both tied to a workspace and an individual project. In the example below, a command is saved to workspace configuration:

{% include image.html file="workspaces/ws_commands.png" %}

Here's how commands can be saved in project configuration:

{% include image.html file="workspaces/project_commands.png" %}

## Runtime

Runtime object is created when a workspace is in a running state. Runtime returns servers URLs (internal or external, depending on server config). Interested clients, like User Dashboard and IDE use these URLs.

{% include image.html file="workspaces/runtime.png" %}
