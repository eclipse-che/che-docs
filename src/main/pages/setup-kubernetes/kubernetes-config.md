---
title: "Configuration: Kuberentes"
keywords: kubernetes, configuration
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: kubernetes-config.html
folder: setup-kubernetes
---
## How It Works

You can configure deployment of Che on Kubernetes by editing env variables that are defined in [che-kubernetes.yaml](https://github.com/eclipse/che/blob/master/dockerfiles/init/modules/kubernetes/files/che-kubernetes.yaml) file. Once done, execute `kubectl --namespace=che apply -f che-kubernetes.yaml `. Che deployment will be updated which automatically triggers a new deployment. This page focuses on some of the envs. You can either look at [Docker configuration page][docker-config] or [che.env](https://github.com/eclipse/che/blob/master/dockerfiles/init/manifests/che.env) file.

We use recreate strategy. When the initial Che pod is shut down, server forcefully stops all workspace pods. Users working in those workspace will see a notification that the workspace is not running anymore. It does not impact data persistence - all workspace project files mounted through PVCs.

## Namespace for Workspaces

You can instruct Che server in what namespace(s) to create workspace pods. There are two scenarios. By default, every new workspace pod is created in a new namespace which is dictated by the following env:

`CHE_INFRA_KUBERNETES_NAMESPACE=""`

You may have one common namespace for all workspace pods:

`CHE_INFRA_KUBERNETES_NAMESPACE="che-workspaces"`

## Volumes

`CHE_INFRA_KUBERNETES_PVC_STRATEGY="unique"`

There are two [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) strategies:

* **unique** - each workspace volume gets own PVC.  This is the default strategy. When a workspace is deleted, associated PVCs are deleted as well. However, an associated PVs may not be recycled and tghus cannot be re-used for a new claim. See [k8s docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recycling).
* **common** - there is one PVC for all workspaces. When a PVC is shared with all workspaces, there's a special service pod that starts before workspace is created to create a subpath in the PV for this particular ws. When a workspace is deleted an associated subpath is deleted as well.

If a common strategy is set, it is impossible to run multiple workspaces simultaneously because of a default `ReadWriteOnce` [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for workspace PVCs.


## HTTPS Mode

Che on Kubernetes doesn't support HTTPS mode yet.

## Scalability

To be able to run more workspaces, [add more nodes to your Kubernetes cluster](https://kubernetes.io/docs/concepts/architecture/nodes/#management). If the system is out of resources, workspace start will fail with an error message returned from Kubernetes (usually it's `no available nodes` kind of error).

## Debug Mode

If you want Che server to run in a debug mode set the following env before running the script (false by default):

`CHE_DEBUG_SERVER=true`

## Image Pull Policy

If you want to always have the latest nightly image or use own latest tags when developing and testing Che

`IMAGE_PULL_POLICY`

## Private Docker Registries

Refer to [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

## Che Server Logs

When Eclipse Che gets deployed to Kubernetes, a PVC `che-data-volume` is [created](https://github.com/eclipse/che/blob/master/deploy/kubernetes/kubectl/che-kubernetes.yaml#L26) and bound to a PV. Logs are persisted in a PV and can be retrieved in the following ways:

* `kubectl get log dc/che`
* `kubectl describe pvc che-data-claim`, find PV it is bound to, then `oc describe pv $pvName`, you will get a local path with logs directory. Be careful with permissions for that directory, since once changed, Che server wont be able to write to a file
* in Kubernetes web console, eclipse-che namespace, **pods > che-pod > logs**.

It is also possible to configure Che master not to store logs, but produce JSON encoded logs to output instead. It may be used to collect logs by systems such as Logstash.
To configure JSON logging instead of plain text environment variable `CHE_LOGS_APPENDERS_IMPL` should have value `json`.
See more at [logging docs][logging].

## Che Workspace Termination Grace Period

Grace termination period of Kubernetes / OpenShift workspace's pods defaults '0', which allows to terminate
pods almost instantly and significantly decrease the time required for stopping a workspace. For increasing grace termination period the following environment variable should be used:

`CHE_INFRA_KUBERNETES_POD_TERMINATION__GRACE__PERIOD__SEC`

<span style="color:red;">**IMPORTANT!**</span>

If `terminationGracePeriodSeconds` have been explicitly set in Kubernetes / OpenShift recipe it will not be overridden by the environment variable.

{% include links.html %}
