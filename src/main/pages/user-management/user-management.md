---
title: "User Management"
keywords: organizations, user management, permissions
tags: [ldap, keycloak]
sidebar: user_sidebar
permalink: user-management.html
folder: user-management
---
{% include links.html %}

## Auth and User Management

Eclipse Che relies on [Keycloak](http://www.Keycloak.org) to create, import, manage, delete and authenticate users. Keycloak uses its own authentication mechanisms and user storage. Eclipse Che requires a Keycloak token when access to Che resources is requested.

Keycloak can create and authenticate users by itself or rely on 3rd party identity management systems and providers.

Default Keycloak credentials are `admin:admin`. You can find your Keycloak URL either in OpenShift web console > keycloak namespace (if you deployed to OpenShift) of go to `$CHE_HOST:5050/auth` if Che is running on Docker. Admin user is also a pre-defined Che user with privileges on the system scope. So, you may use `admin:admin` credentials when loggin in to Che for the first time.

## Che and Keycloak

When Che is deployed on OpenShift or installed on Docker, either deployment script or CLI makes sure that Keycloak is properly configured. When a `che-public` client is created, there are two important fields to be populated:

* **Valid Redirect URIs** need to be the URL you use to access Che. For example, if your original `CHE_HOST` is `1.1.1.1` but you access Che at `myhost` which is an alias, you will see an error from Keycloak, saying that it's an invalid `redirectURI`. So, if this error occurs, go to Keycloak administration console and check valid Redirect URIs.
* **Web Origins** - the same concerns Web Origins. An invalid web origin causes CORS error.


## User Federation

Keycloak provides a user friendly page to [connect LDAP/Active Directory](http://www.keycloak.org/docs/3.2/server_admin/topics/user-federation.html). There are a number of [fields to be populated](http://www.keycloak.org/docs/3,2/server_admin/topics/user-federation/ldap.html) on the config page, and those are specific to your particular LDAP instance, user filters, preferable mode etc. It is possible to test connection and authentication even before saving any particular storage provider.

## Social Login and Brokering

Keycloak offers social login buttons such as GitHub, Facebook, Twitter, OpenShift etc. See: Instructions to [enable Login with GitHub](http://www.keycloak.org/docs/3.2/server_admin/topics/identity-broker/social/github.html).

If you add GitHub login, you can also enable ssh key upload to Che users' GitHub accounts. To enable this feature, make sure scopes are `repo,user,write:public_key`, and Store Tokens, Stored Tokens Readable are **ON** when you register a GitHub identity provider.

{% include image.html file="git/kc_provider.png" %}

Next thing is to add a default read-token role:

{% include image.html file="git/kc_roles.png" %}

Read more about [SHH key management](ide_projects.html#project-import-and-ssh-connection).

## Protocol Based Providers

Keycloak provides support for [SAML v2.0](http://www.Keycloak.org/docs/3.2/server_admin/topics/identity-broker/saml.html) and [OpenID Connect v1.0](http://www.Keycloak.org/docs/3.2/server_admin/topics/identity-broker/oidc.html) protocols so you can connect your identity provider systems if they support these protocols.

## Managing Users

There's UI to add, delete and edit users. See: [Keycloak User Management](http://www.Keycloak.org/docs/3.2/server_admin/topics/users.html).

## SMTP Configuration/Email Notifications

Eclipse Che does not provide any out-of-the-box SMTP servers. This functionality is enabled in Keycloak itself, `che realm settings > Email`. You will need to provide host, port, username and password, if necessary. Eclipse Che is shipped with the default theme that is used for email templates (registration, email confirmation, password recovery, failed login etc).
