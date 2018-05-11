---
title: "Che on OpenShift: Admin Guide"
keywords: openshift, configuration, admin guide
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: openshift-admin-guide.html
folder: setup-openshift
---

{% include links.html %}
{% include_relative admin-guide.md %}

## Create workspace objects in personal namespaces

When Che is installed on Openshift in multi-user mode, it is possible to register the Openshift server into the Keycloak server as an identity provider,
in order to allow creating workspace objects in the personal OpenShift namespace of the user that is currenlty logged in Che through Keycloak.

This feature is available only when Che is confirgured to create a new OpenShift namespace for every Che workspace.

To enable this feature, the administrator should:
- register, inside Keycloak, an Openshift identity provider that will point to the Openshift console of the cluster in which the workspace resources should be created,
- configure Che to use this Keycloak identity provider in order to retrieve the Openshift tokens of Che users.

Once this is done, every interactive action done by a Che user on workspaces, such as start or stop, will create OpenShift resources under his personal OpenShift account.
And the first time the user will try to do it, he will be asked to link his Keycloak account with his personal Openshift account,
which he can do by simply following the provided link in the notification message.

But for non-interactive workspace actions, such as workspace stop on idling or Che server shutdown, the account used for operations on OpenShift resources will 
fall back to the dedicated OpenShift account configured for the Kubernetes infrastructure, as described in the [AdminGuide](admin-guide#who-creates-workspace-objects).

To install Che on OpenShift with this feature enabled, see [this section for Minishift](openshift-multi-user#creating-workspace-resources-in-personal-openshift-accounts-on-minishift)
and [this one for OCP](openshift-multi-user#creating-workspace-resources-in-personal-openshift-accounts)

#### OpenShift identity provider registration

TBD

#### Che configuration

On the Che deployment configuration:
- the `CHE_INFRA_OPENSHIFT_PROJECT` environment variable should be set to `NULL` to ensure a new distinct OpenShift namespace is created for every started workspace.
- the `CHE_INFRA_OPENSHIFT_OAUTH__IDENTITY__PROVIDER` environment variable should be set to the alias of the OpenShift identity provider
registered in Keycloak. The default value is `openshift-v3`.

#### Providing the Openshift certificate to Keycloak

If the certificate used by the Openshift console is self-signed or is not trusted, then by default the Keycloak will not be able to
contact the Openshift console to retrieve linked tokens.

In this case the OpenShift console certificate should be passed to the Keycloak deployment as an additional environment property.
This will enable the Keycloak server to add it to its list of trusted certificates, and will fix the problem.

The environment variable is named `OPENSHIFT_IDENTITY_PROVIDER_CERTIFICATE`.

Since adding a multi-line certificate content in a deployment configuration environment variable is not that easy, the best way is to use a secret that contains the certificate,
and refer to it in the environment variable.
