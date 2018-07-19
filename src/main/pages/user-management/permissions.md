---
title: "Permissions"
keywords: organizations, user management, permissions
tags: [organizations]
sidebar: user_sidebar
permalink: permissions.html
folder: user-management
---
{% include links.html %}

## Overview

Permissions are used to control user actions. Rather than providing a fixed set of roles we use a broader set of permissions that can be applied in any combination of objects to establish the security model you need.

Che also provides a mechanisms and layers which allow to define "who" is allowed to do "what". Any user and administrator can control resources managed by Che and allow certain actions or behaviors for other users or groups. For example as workspace owner you can grant other users permission to see and/or use your workspace.

Permissions can be applied to:
- Workspace
- Organization
- Stack
- System

## Workspace Permissions

The user who creates a workspace is the _workspace owner_ and has all permissions by default. Workspace owners can invite other users into the workspace and control their permissions for the workspace.

The following permissions are applicable to workspaces:

| Permission      | Description                                             |
| --------------- | ------------------------------------------------------- |
| read            | Allows reading workspace configuration.
| use             | Allows using a workspace and interacting with it.
| run             | Allows starting and stopping a workspace.
| configure       | Allows defining and changing workspace configuration.
| setPermissions  | Allows updating workspace permissions for other users.
| delete          | Allows deleting the workspace.

## Organization Permissions

An organization is a named set of users.

The following permissions are applicable to organizations:

| Permission                    | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| update                        | Allows editing of organization settings and information.
| delete                        | Allows deleting an organization.
| manageSuborganizations        | Allows creating and managing sub-organizations.
| manageResources               | Allows redistribution of an organization’s resources and defining resource limits.
| manageWorkspaces              | Allows creating and managing all the organization's workspaces.
| setPermissions                | Allows adding and removing users as well as updating their permissions.

## System Permissions

System permissions control aspects that affect the whole Che installation.

The following permissions are applicable to organizations:

| Permission                    | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| manageSystem                  | Allows control of the system, workspaces and organizations.
| setPermissions                | Allows updating of permissions for users on the system.
| manageUsers                   | Allows creating and managing users.

## Super Priviliged Mode

The permission "manageSystem" can be extended to provide a super privileged mode that allows advanced actions to be performed on any resources managed by the system. A user with "manageSystem" permission is able read and stop any workspaces. To perform other actions on workspaces and organizations, the user will need to assign himself the permissions needed.

By default, this mode is disabled.

It is possible to activate this option by configuring the `CHE_SYSTEM_SUPER_PRIVILEGED_MODE` in the `che.env` file.

## Stack Permissions

A stack is a runtime configuration for a workspace, see [stack definition][stacks].

The following permissions are applicable to a stack:

| Permission                    | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| search                        | Allows searching of the stacks.
| read                          | Allows reading of the stack's configuration.
| update                        | Allows updating of the stack's configuration.
| delete                        | Allows deleting of the stack.
| setPermissions                | Allows managing permissions for the stack.

## Permissions API

All permissions can be managed by using the provided REST API. The APIs are documented using Swagger at `[{host}/swagger/#!/permissions]`.

## List Permissions

List the permissions which can be applied to a specific resources:
`GET /permissions`

Applicable `domain` values are the following:

| Domain                     |
| -------------------------- |
| system                     |
| organization               |
| workspace                  |
| stack                      |

Note: `domain` is optional, in this case the API will return all possible permissions for all domains.

## List Permissions for Specific User

List the permissions which are applied to a specific user:
`GET /permissions/{domain}`

Applicable `domain` values are the following:

| Domain                     |
| -------------------------- |
| system                     |
| organization               |
| workspace                  |
| stack                      |

`instance` parameter corresponds to the ID of the resource you want to get the applied permissions.

## List Permissions for All Users

List the permissions which are applied to a specific user (you must have sufficient permissions to allow you to see this information):
`GET /permissions/{domain}/all`

Applicable `domain` values are the following:

| Domain                     |
| -------------------------- |
| system                     |
| organization               |
| workspace                  |
| stack                      |

`instance` parameter corresponds to the ID of the resource you want to get the applied permissions for all users.

## Assign Permissions

Assign permissions to a resource:
`POST /permissions`

Applicable `domain` values are the following:

| Domain                     |
| -------------------------- |
| system                     |
| organization               |
| workspace                  |
| stack                      |

`instance` parameter corresponds to the ID of the resource you want to get the applied permissions for all users.

`userId` parameter corresponds to the ID of the user who want to grant certain permissions.

Sample `body` to grant user `userID` permissions to a workspace `workspaceID`:

```json
{
  "actions": [
    "read",
    "use",
    "run",
    "configure",
    "setPermissions"
  ],
  "userId": "userID",
  "domainId": "workspace",
  "instanceId": "workspaceID"
}
```
## Sharing Permissions

A user with `setPermissions` privileges can share a workspace, i.e. grant other users `read, use, run, configure or setPermissions` privileges.

Select a workspace in User Dashboard, navigate to `Share` tab and enter emails of users to share this workspace with (use comma or space as separator if there are multiple emails).
