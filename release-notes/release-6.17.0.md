## Release summary

Eclipse Che 6.17 includes:

* **Improvements to workspace monitoring metrics**: Added a Prometheus metric to count the number of
workspace failures
* **New Factory and Container plug-in releases**: 

## Quick Start

Che is a cloud IDE and containerized workspace server - get started on:

* Kubernetes ([single-user](https://www.eclipse.org/che/docs/che-6/kubernetes-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/che-6/kubernetes-multi-user.html))
* OpenShift ([single-user](https://www.eclipse.org/che/docs/che-6/openshift-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/che-6/openshift-multi-user.html))
* Docker ([single-user](https://www.eclipse.org/che/docs/che-6/docker-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/che-6/docker-multi-user.html))
* Try Eclipse Che live at [https://che.openshift.io](https://che.openshift.io)

Learn more in our documentation and start using a shared Che server or local instance today.

## Release details

### Improvements to workspace monitoring metrics

As part of the improvements in the monitoring and tracing of workspaces, we have added several new
metrics in this release. The Prometheus metrics exposed by the Che server now include the 
`che_workspace_status` and `che_workspace_failure_total` metrics, allowing users to track the count
of workspaces per status (`STARTING`, `RUNNING` `STOPPING` or `STOPPED`), and the total number of
failed workspaces. Server operators can see when workspaces are failing by using a `while` tag,
which recognizes `STARTING`, `RUNNING` or `STOPPING` values respectively. These new metrics enable
operators to proactively identify when there are issues with workspaces.

### Use new Factory and Containers plug-ins

The [Factory](https://github.com/eclipse/che-theia/tree/master/plugins/factory-plugin) and [Containers](https://github.com/eclipse/che-theia/tree/master/plugins/containers-plugin) plug-ins for Theia have received updates, and this release of Eclipse Che used the new releases of these plug-ins. The Containers plug-in enables a developer to see a list of containers in a developer workspace, with their status, and provides the ability to open a terminal for a selected container. The Factory plug-in enables Theia to retrieve a factory definition, check out the right branch of the source code, and perform any post-initialization actions once the workspace has been initialised by the Che workspace manager.

We have also evolved the Factory capability of Eclipse Che to use the new “devfile” format, which is a new and improved way to define a developer workspace for Che and other developer workspace managers.

**Pull requests**:

* Use new Factory and Containers plugins: https://github.com/eclipse/che/pull/12396
Factory support of devfile: https://github.com/eclipse/che/pull/12232
