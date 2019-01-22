# Eclipse Che 6.16 Release Notes

////

Heading for blog post

## $HIGHLIGHT1 $HIGHLIGHT2 $HIGHLIGHT3

////

The Eclipse Che 6.16 release contains the following notable features:

* Run Eclipse Che over https with a self-signed certificate
* $HIGHLIGHT2
* $HIGHLIGHT3

---

Intro paragraph

---

## Quick Start

Che is a cloud IDE and containerized workspace server - get started on:

* Kubernetes ([single-user](https://www.eclipse.org/che/docs/kubernetes-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/kubernetes-multi-user.html))
* OpenShift ([single-user](https://www.eclipse.org/che/docs/openshift-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/openshift-multi-user.html))
* Docker ([single-user](https://www.eclipse.org/che/docs/docker-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/docker-multi-user.html))
* Try Eclipse Che live at [https://che.openshift.io](https://che.openshift.io)

Learn more in our [documentation](https://www.eclipse.org/che/docs/infra-support.html) and start using a shared Che server or local instance today.

---

## Run Eclipse Che over https with a self-signed certificate

![Che_on_https](https://www.eclipse.org/che/docs/images/workspaces/chrome_cert.png)

Security is increasingly important for web services, and many Eclipse Che users would like to ensure communication between the Che server and client is encrypted and authenticated. In previous versions, it was not possible to start workspaces in Eclipse Che if your container platform was using a self-signed certificate. In this release, we have added that ability. The Che administrator can enable this feature by creating a secret with the certificate, and configuring the server to ensure that the certificate is used by the Che server.

For more information, see https://www.eclipse.org/che/docs/che-6/openshift-config.html#https-mode---self-signed-certs

Links to PRs:
[https://github.com/eclipse/che/pull/12089](https://github.com/eclipse/che/pull/12089)
[https://github.com/eclipse/che/pull/12112](https://github.com/eclipse/che/pull/12112)

---

## $HIGHLIGHT2

Screenshot/illustration

Description

Links to PRs

---

## $HIGHLIGHT3

Screenshot/illustration

Description

Links to PRs

---

## N Improvements

The Che team has made over 130 changes in the $RELEASE release, touching every part of the project. It is difficult to do them justice here, you can read [the full ChangeLog](https://github.com/eclipse/che/blob/master/CHANGELOG.md#6130-2018-10-24) in the project's source code repository.

---

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)

---

## Contributing

The Eclipse Che project is always looking for user feedback and new contributors! [Find out how you can get involved and help make Che even better](https://github.com/eclipse/che/blob/master/CONTRIBUTING.md).

## Getting involved

You can reach the Eclipse Che community in a number of ways:

* Create an issue in the [Eclipse Che GitHub repository](https://github.com/eclipse/che/)
* Send an email to the [che-dev mailing list](https://accounts.eclipse.org/mailing-list/che-dev) at eclipse.org
* Join us on [the eclipse-che channel on mattermost.eclipse.org](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) to chat in real-time
* Follow us on Twitter [@eclipse_che](https://twitter.com/eclipse_che)
