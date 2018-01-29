---
title: "Environment variables"
keywords: workspace, runtime, recipe, docker, stack, environment variables, env, envs
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: env_variables.html
folder: workspaces
---

{% include links.html %}

Environment variables are defined per machine. Depending on the infrastructure, they are added either to container or Kubernetes pod definition. You can add, edit and remove environment variables either in User Dashboard or directly in workspace machine configuration:

```json
"env": {
  "key": "value"
    }
```

You can use environment variables in applications running in a workspace, [commands][commands_ide_macro] and in the terminal. Che server also injects some environment variables that a user does not control, though they are available to use in case you need them (API endpoint, workspace ID etc).

{% include image.html file="workspaces/env_variable.png" %}
