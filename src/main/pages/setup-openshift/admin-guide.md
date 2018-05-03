{% include links.html %}

## Examples

All examples use `kubectl` command. OpenShift admins should use `oc`

## RAM

**Single User**

Che server pod consumes up to 1GB RAM. The initial request is 256MB, and server pod rarely consumes more than 800MB. A typical workspace will require 2GB. So, **<span style="color:red;">3GB</span>** is a minimum to try single user Che on OpenShift/Kubernetes.

**Multi-User**

Depending on whether or not you deploy Che bundled with Keycloak auth server and Postgres database, RAM requirements for a multi-user Che installation can vary.

When deployed with Keycloak and Postgres, your Kubernetes cluster should have **at least <span style="color:red;">5GB RAM</span>** available - 3GB go to Che deployments:

* ~750MB for Che server
* ~1GB for Keycloak
* ~515MB for Postgres)
* min 2GB should be reserved to run at least one workspace. The total RAM required for running workspaces will grow depending on the size of your workspace runtime(s) and the number of concurrent workspace pods you run.

## Resource Allocation and Quotas

All workspace pods are created either in the same namespace with Che itself, a dedicated namespace, or a new namespace is created for every workspace. In both cases, pods are are created in the account of a user who deployed Che (if che service account is used to create ws objects) or account of a user whose token/credentials are used in Che deployment env.

Therefore, an account where Che pods are created (including workspace pods) should have reasonable quotas for RAM, CPU and storage, otherwise, workspace pods won't be created.

## Who Creates Workspace Objects?

All workspace objects for all Eclipse Che users are **created on behalf of one OpenShift user**, typically the one who deployed Che or whose credentials or token is used in Che deployment environment. Eclipse Che uses fabric8 client to talk to Kubernetes/OpenShift API, and the client uses token, username/password or service account, if available.

* If you passed `CHE_INFRA_KUBERNETES_USERNAME` and `CHE_INFRA_KUBERNETES_PASSWORD` to Che deployment, those credentials will be used to create workspace objects.

* If there's `CHE_INFRA_KUBERNETES_OAUTH__TOKEN` fabric8 client will use it. If both are available, token has a priority over username/pass.

* If none are available **che service account** is used to create workspace objects. This is default behavior. Since che service account cannot create objects outside a namespace it's bound to, all workspace objects are created in Che namespace. Admins can grant `che` [service account super user permissions](https://kubernetes.io/docs/admin/authorization/rbac/#service-account-permissions), and this way it will be possible to use this SA to create objects outside Che namespace. OpenShift cluster admins can do it this way using oc CLI:

```bash
oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:eclipse-che:che

# eclipse-che is Che namespace
```

Advantages and disadvantages of using token, username/pass, and service account:

|Auth type         | Pros                                         | Cons |
|**Token**             | Objects can be created outside Che namespace | Tokens tend to expire
|**Username/Password** | Objects can be created outside Che namespace | If username/pass are changed, they need to be updated in Che deployment as well. Many authentication types like oAuth make it impossible to login with username/pass
| **Service account**   | No expiration risks                          | Cannot create objects outside its namespace unless given admin privileges

## Storage Overview

Che server, Keycloak and Postgres pods, as well as workspace pods use PVCs that are then bound to PVs with [ReadWriteOnce access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes). Che PVCs are defined in deployment yamls, while [workspace PVC](#che-workspaces-storage) access mode and claim size is configurable through Che deployment environment variables.

## Che Infrastructure: Storage

* Che server claims 1GB to store logs and initial workspace stacks. PVC mode is RWO
* Keycloak needs 2 PVCs, 1Gb each to store logs and Keycloak data
* Postgres needs one 1GB PVC to store db

## Che Workspaces: Storage

As said above, che workspace PVC access type and claim size is configurable, and so is a workspace PVC strategy:

|strategy       | details       | pros | cons |
|**common**|One PVC for all workspaces, sub-paths pre-created| easy to manage and control storage. no need to recycle PVs when pod with pvc is deleted | ws pods should all be in one namespace
|**unique**|PVC per workspace| Storage isolation | An  undefined number of PVs is required |

## Common PVC Strategy

**How it Works**

When a common PVC strategy is used, **all workspaces use the same PVC** to store data declared in their volumes (projects and workspace-logs by default and whatever additional [volumes][volumes] that a user can define.)

In case of a common strategy, an PV that is bound to PVC `che-claim-workspace` will have the following structure:

```bash
pv0001
  workspaceid1
  workspaceid2
  workspaceidn
    che-logs projects <volume1> <volume2>
```
Directory names are self explaining. Other volumes can be anything that a user defines as volumes for workspace machines (volume name == directory name in `${PV}/${ws-id}`)

When a workspace is deleted, a corresponding subdirectory (`${ws-id}`) is deleted in the PV directory.

**How to enable common strategy**

Set `CHE_INFRA_KUBERNETES_PVC_STRATEGY` to `common` in dc/che if you have already deployed Che with unique strategy, or pass `-p CHE_INFRA_KUBERNETES_PVC_STRATEGY=common` to oc new-app command when applying `che-server-template.yaml`. See: [Deploy to OpenShift][openshift-multi-user].

**What's CHE_INFRA_KUBERNETES_PVC_PRECREATE__SUBPATHS?**

Pre 1.6 Kubernetes created subpaths within a PV with invalid permissions, sot hat a user in a running container was unable to write to mounted directories. When `CHE_INFRA_KUBERNETES_PVC_PRECREATE__SUBPATHS` is `true`, and a common strategy is used, a special pod is started before workspace pod is schedules, to pre-create subpaths in PV with the right permissions. You don't need to set it to true if you have Kubernetes 1.6+.

**Restrictions**

When a common strategy is used, and a workspace PVC access mode is RWO, only one Kubernetes node can simultaneously use PVC. You're fine if your Kubernetes/OpenShift cluster has just one node. If there are several nodes, a common strategy can still be used, but in this case, workspace PVC access mode should be RWM, ie multiple nodes should be able to use this PVC simultaneously (in fact, you may sometimes have some luck and all workspaces will be scheduled on the same node). You can change access mode for workspace PVCs by passing environment variable `CHE_INFRA_KUBERNETES_PVC_ACCESS_MODE=ReadWriteMany` to che deployment either when initially deploying Che or through che deployment update.

Another restriction is that only pods in the same namespace can use the same PVC, thus, `CHE_INFRA_KUBERNETES_PROJECT` env variable should not be empty - it should be either Che server namespace (in this case objects can be created with che SA) or a dedicated namespace (token or username/password need to be used).

## Unique PVC Strategy

It is a default PVC strategy, i.e. `CHE_INFRA_KUBERNETES_PVC_STRATEGY` is set to `unique`. Every workspace gets its own PVC, which means a workspace PVC is created when a workspace starts for the first time. Workspace PVC is deleted when a corresponding workspace is deleted.


## Update

An update implies updating Che deployment with new image tags. There are multiple ways to update a deployment:

* `kubeclt edit dc/che` - and just manually change image tag used in the deployment
* manually in OpenShift web console > deployments > edit yaml > image:tag
* `kubectl set image dc/che che=eclipse/che-server:${VERSION} --source=docker`

Config change will trigger a new deployment. In most cases, using older Keycloak and Postgres images is OK, since changes to those are very rare. However, you may update Keycloak and Postgres deployments:

* eclipse/che-keycloak
* eclipse/che-postgres

You can get the list of available versions at [Che GitHub page](https://github.com/eclipse/che/tags).

Since `nightly` is the default tag used in Che deployment, and image pull policy is set to Always, triggering a new deployment, will pull a newer image, if available.

You can use **IfNotPresent** pull policy (default is Always). Manually edit Che deployment after deployment or add `--set cheImagePullPolicy=IfNotPresent`.

OpenShift admins can pass `-p PULL_POLICY=IfNotPresent` to [Che deployment][openshift-multi-user] or manually edit `dc/che` after deployment.

## Scalability

To be able to run more workspaces, [add more nodes to your Kubernetes cluster](https://kubernetes.io/docs/concepts/architecture/nodes/#management). If the system is out of resources, workspace start will fail with an error message returned from Kubernetes (usually it's `no available nodes` kind of error).

## Debug Mode

If you want Che server to run in a debug mode set the following env in Che deployment to true (false by default):

`CHE_DEBUG_SERVER=true`

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

## Workspace Logs

Workspace logs are stored in an PV bound to `che-claim-workspace` PVC. Workspace logs include logs from workspace agent, [boostrapper][boostrapper] and other agents if applicable.

## Che Master States

There is three possible states of the master - `RUNNING`, `PREPARING_TO_SHUTDOWN` and `READY_TO_SHUTDOWN`.
`PREPARING_TO_SHUTDOWN` state may imply two different behaviors:
 - When no new workspace startups allowed, and all running workspaces are forcibly stopped;
 - When no new workspace startups allowed, any workspaces that are currently starting or stopping is allowed to finish that process,
 and running workspaces doesn't stopped.
This option is possible only for the infrastructures that support workspaces recovery. For those are didn't, automatic fallback to the shutdown with
full workspaces stopping will be performed.
Therefore, `/api/system/stop`  API contract changed slightly - now it tries to do the second behavior by default. Full shutdown with workspaces stop
can be requested with `shutdown=true` parameter.
When preparation process in finished, `READY_TO_SHUTDOWN` state will be set which allows to stop current Che master instance.

## Che Workspace Termination Grace Period

Grace termination period of Kubernetes / OpenShift workspace's pods defaults '0', which allows to terminate
pods almost instantly and significantly decrease the time required for stopping a workspace. For increasing grace termination period the following environment variable should be used:

`CHE_INFRA_KUBERNETES_POD_TERMINATION__GRACE__PERIOD__SEC`

<span style="color:red;">**IMPORTANT!**</span>

If `terminationGracePeriodSeconds` have been explicitly set in Kubernetes / OpenShift recipe it will not be overridden by the environment variable.

##  Recreate Update
To perform Recreate type update without stopping active workspaces:

- Make sure there is full compatibility between new master and old ws agent versions (API etc);
- Make sure deployment update strategy set to Recreate
- Make POST request to the /api/system/stop api to start WS master suspend
(means that all new attempts to start workspaces will be refused, and all current starts/stops will be finished).
Note that this method requires system admin credentials.

- Make periodical GET requests to /api/system/state api, until it returns READY_TO_SHUTDOWN state.
Also, it may be visually controlled by line "System is ready to shutdown" in the server logs
- Perform new deploy.

## Delete deployments

If you want to completely delete Che and its infrastructure components, deleting a project/namespace is the fastest way - all objects associated with this namespace will be deleted:

`oc delete namespace che`

If you need to delete particular deployments and associated objects, you can use selectors (use `oc` instead of `kubctl` for OpenShift):

```bash
# remove all Che server related objects
kubectl delete all -l=app=che
# remove all Keycloak related objects
kubectl delete all -l=app=keycloak
# remove all Postgres related objects
kubectl delete all -l=app=postgres

```
PVCs, service accounts and role bindings should be deleted separately as `oc delete all` does not delete them:

```bash
# Delete Che server PVC, ServiceAccount and RoleBinding
kubectl delete sa -l=app=che
kubectl delete rolebinding -l=app=che

# Delete Keycloak and Postgres PVCs

kubectl delete pvc -l=app=keycloak
kubectl delete pvc -l=app=postgres
```
