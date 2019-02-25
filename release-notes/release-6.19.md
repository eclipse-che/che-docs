# Eclipse Che 6.19.0 Release Notes

The Eclipse Che 6.19.0 release contains the following notable features:

* Incorrect warning no longer emitted to the logs when workspace idling is disabled

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

## Improvements in workspace idling diagnostics

Due to an improvement in Eclipse Che diagnostics of workspace activity, and error handling related to 
and better handling of possible error conditions, we no longer log an unnecessary warning when
workspace idling is disabled.

Concretely, in previous versions, if `CHE_LIMITS_WORKSPACE_IDLE_TIMEOUT` was set to a negative value,
a warning similar to the following is unnecessarily written to the log:

```
2019-02-13 13:19:15,527[ted-scheduler-2]  [WARN ] [a.w.a.WorkspaceActivityChecker 330]  - Found no expiration time on workspace 'workspace5w1v228zcl6sini5'. This was detected 1727206ms after the workspace has been recorded running which is suspicious. Please consider filing a bug report. To restore the normal function, the expiration time has been set to 1550062228321.
```

This has been fixed and should no longer be the case.

Links to PRs
https://github.com/eclipse/che/pull/12718

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

