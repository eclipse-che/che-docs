---
title: "Resource Management"
keywords: organizations, user management, permissions, resource management, RAM allocation
tags: [ldap, keycloak]
sidebar: user_sidebar
permalink: resource-management.html
folder: user-management
---
{% include links.html %}

## Overview

Resource API is designed to help control resources that Che users consume. Che admins can set caps for free resources to each resource type, as well as for each particular account.

There are two kinds of accounts which may be used in Che:

- _personal_ - an account that belongs to a user. Only one user can be related to this type of account and consume resources provided to this account.

- _organizational_ - account that belongs to an [organization][organizations]. This type of account allows consuming related resources for each organization member. The organization can have sub-organizations and distribute resources between them.

Since workspaces are the critical for users in the development flow, resources are mostly related to workspaces and runtimes.

Multi-user Che supports four types of resources:

- __RAM__       - defines the amount of RAM which can be used by running workspaces at the same time;
- __Timeout__   - defines the period of time that is used to control idling of user workspaces;
- __Runtime__   - defines the amount of workspaces which user can run at the same time;
- __Workspace__ - defines the amount of workspaces which user can have at the same time.

## Resource API

__Total resources__

`GET resource/${accountId}:` allows getting information on total resources list that is allowed to use by a specified account;

__Used resources__

`GET resource/{accountId}/used:` allows getting information on used resources list that is consumed by the specified account;

__Available resources__

`GET resource/${accountId}/available:` allows getting information on available resources list that is not used, so if there are no used resources at the moment of the request, the result must equal total resources, otherwise, the result must contain deduction of used resources from total resources list;

__Resource details__

`GET resource/{accountId}/details:` allows getting detailed information about resource list that is provided to the specified account. The result of the request contains information about resource providers and the beginning/end of period of use.

The more detailed specification of the response objects and required parameters are available at Swagger page: `${che-host}/swagger/#/resource`.

## Resource distribution

There are three ways to distribute resources to account:

- Che admin specifies default free resources limit for account by configuration;
- Che admin overrides default free resources limit for account by resource-free API.

## Configuration

Che admin can limit how workspaces are created and the resources that these workspaces consume. Detailed information about each property can be found in  [che.env](https://github.com/eclipse/che/blob/master/dockerfiles/init/manifests/che.env#L538) file.

See: [Docker][docker-config] and [OpenShift][openshift-config] configuration docs.

|Property name                                 |Default Value|Unit     |Description                                                                  |
|----------------------------------------------|-------------|---------|-----------------------------------------------------------------------------|
|`CHE_LIMITS_USER_WORKSPACES_COUNT`            | -1          |item     |count of workspaces Che user is allowed to create                            |
|`CHE_LIMITS_USER_WORKSPACES_RUN_COUNT`        | -1          |item     |count of simultaneously running workspaces for Che user                      |
|`CHE_LIMITS_USER_WORKSPACES_RAM`              | -1          |memory   |amount of RAM all user's workspaces can simultaneously consume               |
|`CHE_LIMITS_ORGANIZATION_WORKSPACES_COUNT`    | -1          |item     |count of workspaces Organization members are allowed to create               |
|`CHE_LIMITS_ORGANIZATION_WORKSPACES_RUN_COUNT`| -1          |item     |count of simultaneously running workspaces by Organization members           |
|`CHE_LIMITS_ORGANIZATION_WORKSPACES_RAM`      | -1          |memory   |amount of RAM all organizations's workspaces can simultaneously consume      |
|`CHE_LIMITS_WORKSPACE_IDLE_TIMEOUT`           | -1          |minutes  |timeout to idle inactive workspaces                                          |
|`CHE_LIMITS_WORKSPACE_ENV_RAM`                | 16gb        |memory   |maximum amount of RAM that workspace environment can use at one              |

## Unit formats:

The value `-1` mean that it is unlimited and any operation aggregation and deduction of resources will return `-1`.

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

`GET resource/free:` allows getting information on free resources list that is provided to this account;

`GET resource/free/{accountId}:` allows getting information on free resources list that is provided to specified account;

__Set Free Resources__

`POST resource/free:` allows setting resource caps for the specified user/organization account. This limits will override Сhe configuration and be used in all further operations with resources;

__Remove Free Resources__

`DELETE resource/free/{accountId}:` allows resetting free resources limit for the specified user/organization account. The default limit that is specified in configuration is used.

The more detailed specification of the response objects and required parameters are available at Swagger page: `{che-host}/swagger/#/resource-free`.

## Organization Resource API

__Distributed Organization Resources__

`GET organization/resource/{organizationId}:` allows getting information on total resources list that is provided to sub-organization by its parent organization;

__Sub-Organization Resources Cap__

`GET organization/resource/{suborganizationId}/cap:` allows getting information on resources caps that are set for a sub-organization; By default, sub-organization is able to use all parent organization resources;

__Set Sub-Organization Resources Cap__

`POST organization/resource/{suborganizationId}/cap:` allows set up resources caps for a sub-organization; Caps allow limiting usage of shared resources by sub-organization.

More detailed specification of response objects and required parameters are available at Swagger page: `{che-host}/swagger/#/organization-resource`.
