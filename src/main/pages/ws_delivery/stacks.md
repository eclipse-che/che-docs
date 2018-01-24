---
title: "Stacks"
keywords: workspace, runtime, recipe, docker, stack
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: stacks.html
folder: ws_delivery
---

{% include links.html %}

## What Are Stacks

A stack is a template of [workspace configuration][workspace_data_model] and some meta-information like scope, tags, components, description, name and ID. Stacks are used by User Dashboard to make it easy to create workspaces and well as filter sample projects compatible with a chosen stack.

Stacks are displayed in User Dashboard on Create a workspace page. You can filter them by type (single vs multi machine), scope (the ones displayed by default vs others), as well as search for a stack by keyword.

## Stacks Loading

Stacks are loaded from a JSON file that is packaged into resources of a special component deployed with a workspace master. This JSON isn't exposed to users and stack management is performed in User Dashboard (that uses REST API).

Stacks are loaded from a JSON file only when the database is initialized, i.e. when a user first stats Che. This is the default policy that can be changed. To keep getting updates with new Che stacks, set `CHE_PREDEFINED_STACKS_RELOAD__ON__START=true` in `che.env`. When set to true, `stacks.json` will be used to update Che database, each time Che server starts. This means Che will get all stacks in stacks.json and upload them to a DB. This way, you may make sure that you keep existing custom stacks (user-created) and get stack updates from new Che releases. New and edited stacks (for example those with fixes in stack definition) will be merged in. Conflicts are possible though, since for example, if a new Che version provides a new stack with the name "My Cool Stack" and a stack with this name somehow exists in a database, such a stack won't be saved to a DB.
