---
title: "Single and Multi-User Che"
keywords: single-user, Eclipse Che
tags: [installation, getting-started]
sidebar: user_sidebar
permalink: single-multi-user.html
folder: overview

---

Che is shipped as two different flavors - single and multi user. A single user Che **has no components that provide multi tenancy and permissions**. Thus, Che server and workspaces are not secured. This makes a single user Che a good choice for developers working locally.

A multi user Che provides multi-tenancy i.e. **users accounts and workspaces are isolated and secured** with Keycloak tokens. Che uses [Keycloak](http://www.keycloak.org/) as a mechanism to register, manage and authenticate users. Permissions API regulates access to different entities in Che, such as workspaces, stacks, recipes, organizations etc. User information is stored in a persistent DB that supports migrations (PostgreSQL).

If you plan using Che just on your local machine or just evaluate the platform, it is reasonable to start with a **single-user Che**.

**Single User Che Pros:**

* The CLI will pull fewer Images
* You will get to the User Dashboard more quickly (no login)

**Multi-User Che Pros**

* A Fully functional web IDE with fine grained access controls
* A standalone Keycloak server that supports users federation and identity providers

By default **Che gets deployed as a single user** assembly both on Docker and OpenShift. Special flags must be provided to enable multi-user functionality.


Proceed to installation:
- Installing it on Docker: [Single-user][docker-single-user] or [Multi-user][docker-multi-user]
- Installing it on OpenShift: [Single-user][openshift-single-user] or [Multi-user][openshift-multi-user]

{% include links.html %}
