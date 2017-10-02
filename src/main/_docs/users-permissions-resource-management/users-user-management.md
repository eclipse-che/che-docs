---
tags: [ "eclipse" , "che" ]
title: Multi-User Setup
excerpt: ""
layout: docs
permalink: /:categories/user-management/
---
{% include base.html %}

# User Management in Che

Eclipse Che relies on KeyCloak to create, import, manage, delete and authenticate users. KeyCloak uses own authentication mechanisms and user storage. Eclipse Che requies KeyCloak token to validate it when access to Che resources is requested.

## User Federation

keycloak provides a user friendly page to [connect LDAP/Active Directory](http://www.keycloak.org/docs/latest/server_admin/topics/user-federation.html). There are a number of [fields to be populated](http://www.keycloak.org/docs/latest/server_admin/topics/user-federation/ldap.html) on the config page, and those are specific to your particular LDAP instance, user filters, preferable mode etc. It is possible to test connection and authentication even before saving any particular storage provider.

## Social Login

KeyCloak offers social login buttons such as GitHub, Facebook, Twitter, OpenShift etc. See: Instructions to [enable Login with GitHub](http://www.keycloak.org/docs/latest/server_admin/topics/identity-broker/social/github.html).

# SMTP Configuration/Email Notifications

Eclipse Che does not provide any out-of-the-box SMTP servers. This functionality is enabled in KeyCloak itself, Che real settings > Email. You will need to provide host, port, username and password, if necessary. Eclipse Che is shipped with the default theme that is used for email templates itself (registration, email confirmation, password recovery, failed login etc).
