# Eclipse Che 6.18.0 Release Notes

The Eclipse Che 6.18.0 release contains the following notable features:
 
* Add Vue.js language support
* Improvements for Persistent Volume Claim (PVC) handling
* Support for mounting workspace source code in consistent location for all workspace containers

---

Eclipse Che 6.18.0 is out now, complete with new language support in the Web plugin for Vue.js,
and a number of improvements related to workspace storage and PVC handling.

---

## Quick Start

Che is a cloud IDE and containerized workspace server - get started on:

* Kubernetes ([single-user](https://www.eclipse.org/che/docs/kubernetes-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/kubernetes-multi-user.html))
* OpenShift ([single-user](https://www.eclipse.org/che/docs/openshift-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/openshift-multi-user.html))
* Docker ([single-user](https://www.eclipse.org/che/docs/docker-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/docker-multi-user.html))
* Try Eclipse Che live at [https://che.openshift.io](https://che.openshift.io)

Learn more in our [documentation](https://www.eclipse.org/che/docs/infra-support.html) and start using a shared Che server or local instance today.

---

## Add VueJS language support

Thank you to [@demsking](https://github.com/demsking) for a pull
request which adds support for [VueJS](https://vuejs.org/) to the
[Web plugin](https://github.com/eclipse/che/tree/master/plugins/plugin-web).
Vue.js is a Javascript framework for building user interfaces. This support
includes syntax highlighting and Intellisense.

**Pull Request:**

* Web Plugin: Add VueJS Language Support: https://github.com/eclipse/che/pull/12470
---

## Improvements for Physical Volume Claim (PVC) handling

![Ephemeral mode switch](https://user-images.githubusercontent.com/1611939/51479083-f50b4580-1d95-11e9-9eb7-0b0e3351cda8.png)

This release contains a number of changes which improve PVC handling for
users. We have made it easier for users to use ephemeral storage for
workspaces by adding an option to enable ephemeral mode in the workspace
creation page. In addition, we have added the ability to define the PVC
strategy in the Kubernetes or OpenShift deployment scripts.

If you have ever had a workspace fail to start because of a PVC issue, you
know that it can sometimes be hard to find the root cause afterwards. In
this release, when there is an error related to a PVC, we can now send the
full log trace to the host platform (Kubernetes or OpenShift), making it
easier for the cluster administrator to diagnose storage-related issues.

**Links to PRs:**

* Added support of PVC in Kubernetes/OpenShift recipe: https://github.com/eclipse/che/pull/12335
* Add ability to configure workspace ephemeral mode: https://github.com/eclipse/che/pull/12483
* Get logs from PVC helper pods when job fails: https://github.com/eclipse/che/pull/12514

---

## Support for mounting workspace source code in consistent location for plugin containers

Che plugins can now declare that they want the sources of the workspace projects available in their
containers.

In the `che-plugin.yaml` file, the plugin author can set the new `mountSources` attribute to `true` on
each container which should have access to the sources. Che will make sure that the volume with
the source code is mounted to the container. The mount location is consistent across all plugin
containers, which enables different plugins to cooperate and "talk" about the same files in the
projects. The project's source path is available in the `CHE_PROJECTS_ROOT` environment variable
during container startup and run time.

**Links to PRs:**
https://github.com/eclipse/che-plugin-broker/pull/27
https://github.com/eclipse/che/pull/12527

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

