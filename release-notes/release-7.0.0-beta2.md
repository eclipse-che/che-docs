# Eclipse Che 7.0.0.Beta2 Release Notes

////

Heading for blog post

## $HIGHLIGHT1 $HIGHLIGHT2 $HIGHLIGHT

////

The Eclipse Che 7.0.0.Beta2 release contains the following notable features:
 
* Workspace factory support for arbitrary repositories storing devfile

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

## Workspace factory support for arbitrary repositories storing devfile

When an URL to the devfile is passed to the workspace factory it is now assumed that the files that are referenced in the devfile are accessible on the same 
host and the path to them is relative to the location of the devfile.

This works great with links to the "raw" contents of the files on popular git repositories, e.g.:

* `https://raw.githubusercontent.com/<organization>/<project>/master/.devfile.yaml`
* `https://gitlab.com/<organization>/<project>/raw/master/.devfile.yaml`
* `https://git.eclipse.org/c/<dir>/<project>.git/plain/ide-config/.devfile.yaml`

It will even work with files stored on any accessible HTTP server as long as all the referenced files are stored on the the server on paths corresponding to 
their relative location specified in the devfile.

Links to PRs

https://github.com/eclipse/che/pull/12800

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

