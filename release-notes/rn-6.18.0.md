# Eclipse Che 6.18 Release Notes

////

Heading for blog post

## $HIGHLIGHT1 $HIGHLIGHT2 $HIGHLIGHT3

////

The Eclipse Che 6.18 release contains the following notable features:
 
* Improved debugging of Che server on Kubernetes and Openshift
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

## Improved debugging of Che server on Kubernetes and Openshift

This is a feature aimed primarily at the developers of Che itself.

The `CHE_DEBUG_SUSPEND` environment variable now also works on Kubernetes and Openshift deployments
of Che server. Setting this flag to `true` and (re)starting a Che server deployment makes the server
wait for a connection from a debugger on port 8000 before starting up. This is invaluable for
debugging the server startup. 

To connect your local IDE to the server, you first need to forward the port so that you can use it
on `localhost`, e.g. on Openshift:

```bash
oc get pods
oc port-forward <CHE_POD> 5005:8000

```

where `<CHE_POD>` is the name of the che server pod obtained from `oc get pods`.

After this, you will be able to connect your Java debugger of choice to `localhost:5005` and
initiate a remote debugging session of the Che server.

On Kubernetes, simply exchange `oc` with `kubectl` in the example above.

Links to PRs
https://github.com/eclipse/che/pull/12416

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

