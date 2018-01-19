---
title: "Resource Management"
keywords: organizations, user management, permissions, resource management, RAM allocation
tags: [ldap, keycloak]
sidebar: user_sidebar
permalink: resource-management.html
folder: multiuser
---
{% include links.html %}

## Overview

Resource API is designed to help control the resources that Che users consume. Che admins can set up the limits for free resources to each resource type, for each particular account.

There are two kinds of account which may be used in Che:

- _personal_ - is an account of a user. Only one person can be related to this type of account and consume the resources provided to this account.

- _organizational_ - is an account of an organization . This type of account allows consuming the related resources to each organization member. The organization can have sub-organizations and distribute resources to them.

Since the workspaces are the fundamental runtime for users when doing development, the most part of the resources are related to them.

Multiuser Che supports four types of resources:

- __RAM__       - defines the amount of RAM which can be used by running workspaces at the same time;
- __Timeout__   - defines the period of time that is used to control idling of user workspaces;
- __Runtime__   - defines the amount of workspaces which user can run at the same time;
- __Workspace__ - defines the amount of workspaces which user can have at the same time.

## Resource API

__Total resources__

`GET resource/${accountId}:` allows getting an information about total resources list that is allowed to use by a specified account;

__Used resources__

`GET resource/{accountId}/used:` allows getting an information about used resources list that is consumed by the specified account;

__Available resources__

`GET resource/${accountId}/available:` allows getting an information about available resources list that is not used, so if there are no used resources at the moment of the request the result must be equal to total resources, otherwise, the result must contain deduction of used resources from total resources list;

__Resource details__

`GET resource/{accountId}/details:` allows getting a detailed information about a resource list that is provided to the specified account. The result of the request contains the information about resource providers and the beginning/end of the period of use.

The more detailed specification of the response objects and required parameters are available by using the swagger by path: `{che-host}/swagger/#/resource`.

## Resource distribution

There are three ways to distribute resources to account:

- Che admin specifies default free resources limit for account by configuration;
- Che admin overrides default free resources limit for account by resource-free API.

## Configuration
By this set of parameters Che admin can limit how workspaces are created and the resources that are consumed. Detailed information about each property can be found in  [che.env](https://github.com/eclipse/che/blob/master/dockerfiles/init/manifests/che.env#L538) file.

|Property name                                 |Default Value|Unit     |Description                                                                  |
|----------------------------------------------|-------------|---------|-----------------------------------------------------------------------------|
|`che.limits.user.workspaces.count`            | -1          |item     |count of workspaces allowed to create for Che user                           |
|`che.limits.user.workspaces.run.count`        | -1          |item     |count of simultaneously running workspaces for Che user                      |
|`che.limits.user.workspaces.ram`              | -1          |memory   |amount of RAM allowed to consume by Che user                                 |
|`che.limits.organization.workspaces.count`    | -1          |item     |count of workspaces allowed to create by Organization members                 |
|`che.limits.organization.workspaces.run.count`| -1          |item     |count of simultaneously running workspaces by Organization members |
|`che.limits.organization.workspaces.ram`      | -1          |memory   |amount of RAM allowed to consume by Organization members                      |
|`che.limits.workspace.idle.timeout`           | -1          |minutes  |the time frame for workspace idling                                          |
|`che.limits.workspace.env.ram`                | 16gb        |memory   |maximum amount of RAM that is possible to use by one environment             |

### Unit formats:

The value `-1` mean that it is limitless and any operation aggregation and deduction of resources will return `-1`.

 - `memory` - measured in bytes. This value can be defined as a plain integer or as a fixed-point integer using one of following suffixes:

| Suffix name        | Description                 |
| ------------------ | --------------------------- |
| `k` / `kb` / `kib` | kilo bytes   `1k` = `1024b` |
| `m` / `mb` / `mib` | mega bytes   `1m` = `1024k` |
| `g` / `gb` / `gib` | giga bytes   `1g` = `1024m` |
| `t` / `tb` / `tib` | terra bytes  `1t` = `1024g` |
| `p` / `pb` / `pib` | peta bytes   `1p` = `1024t` |

- `item` - the integer describing the number of objects;
- `minutes` - the time frame, which is specified in integer value of minutes.

## Resource-free API

Allows managing free resources that are provided by configuration and can be overridden for the particular account.

__Free Resources__

`GET resource/free:` allows getting an information about free resources list that is provided to this account;

`GET resource/free/{accountId}:` allows getting an information about free resources list that is provided to specified account;

__Set Free Resources__

`POST resource/free:` allows setting the limits of resources for the specified user/organization account. This limits will override the configuration of Сhe and will be used in all further operations with resources;

__Remove Free Resources__

`DELETE resource/free/{accountId}:` allows reset free resources limit for the specified user/organization account. Then default limit that is specified in configuration will be used.

The more detailed specification of the response objects and required parameters are available by using the swagger by path: `{che-host}/swagger/#/resource-free`.

## Organization Resource API

__Distributed Organization Resources__

`GET organization/resource/{organizationId}:` allows getting an information about total resources list that is provided to sub-organization by its parent organization;

__Sub-Organization Resources Cap__

`GET organization/resource/{suborganizationId}/cap:` allows getting an information about resources caps that are set for a sub-organization; By default, sub-organization is able to use all parent organization resources;

__Set Sub-Organization Resources Cap__

`POST organization/resource/{suborganizationId}/cap:` allows set up an resources caps for a sub-organization; Cap allow to limit usage of shared resources by sub-organization.

The more detailed specification of the response objects and required parameters are available by using the swagger by path: `{che-host}/swagger/#/organization-resource`.
