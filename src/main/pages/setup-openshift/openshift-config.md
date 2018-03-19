---
title: "Configuration: OpenShift"
keywords: openshift, configuration
tags: [installation, openshift]
sidebar: user_sidebar
permalink: openshift-config.html
folder: setup-openshift
---
## How It Works

You can configure deployment of Che on OpenShift 3.6+ with env variables that are defined in [`che-config`](https://raw.githubusercontent.com/eclipse/che/master/dockerfiles/init/modules/openshift/files/scripts/che-config) file. If you have downloaded only deployment script but need to configure your Che server, download config file that should be located in the same directory with the deployment script.

Once done, run the deployment script with `-c rollupdate` flag. Che deployment will be updated which automatically triggers a new deployment. You can also export envs in your environment, and the script will pick them up. It will only update Che server pod. This page focuses on some of the envs. You can either look at [Docker configuration page][docker-config] or [che.env](https://github.com/eclipse/che/blob/master/dockerfiles/init/manifests/che.env) file.

We use recreate strategy. When the initial Che pod is shut down, server forcefully stops all workspace pods. Users working in those workspace will see a notification that the workspace is not running anymore. It does not impact data persistence - all workspace project files mounted through PVCs.

## Update

Export `CHE_IMAGE_TAG=${VERSION}` before executing `che_deploy.sh -c rollupdate`, where `${VERSION}` is a tag you want to update to. If you have your custom Che server image, you may export `CHE_IMAGE_REPO` too. You can get available tags on [Github](https://github.com/eclipse/che/tags) or [DockerHub](https://hub.docker.com/r/eclipse/che/tags/).

If you want to always use the latest nightly builds, run `export IMAGE_PULL_POLICY=Always` and then re-run the deployment script. This way, OpenShift will always pull the image referenced in the deployment.

Downgrades are possible, however, if database migrations have been previously performed, Che pod will fail to start.


## OpenShift Flavor

`OPENSHIFT_FLAVOR` defaults to `minishift`. Allowed values: `ocp`, `osio`

## Username, Password, Token

Deployment script needs access to a running OpenShift instance either via username/password or a token:

```
CHE_INFRA_KUBERNETES_USERNAME
CHE_INFRA_KUBERNETES_PASSWORD
CHE_INFRA_KUBERNETES_TOKEN
```
If token is set, it is used by `oc` client to log in and Che server to create namespaces and objects, else default credentials are used (`developer/developer`) for MiniShift and OCP.

All objects that Che server creates such as workspace pods, services, routes and PVCs are created on behalf of this user. As a result, other OpenShift users who create workspaces in a multi-user Che, have no access to these objects.

This is going to be changed once [this issue](https://github.com/eclipse/che/issues/8178) is completed.

## Namespace for Workspaces

You can instruct Che server in what namespace(s) to create workspace pods. There are two scenarios. By default, every new workspace pod is created in a new namespace which is dictated by the following env:

`CHE_INFRA_OPENSHIFT_PROJECT=""`

You may have one common namespace for all workspace pods:

`CHE_INFRA_OPENSHIFT_PROJECT="che-workspaces"`

If workspaces are created in the same namespace with Che server, a service account may be used instead of a token or credentials.

## Volumes

`CHE_INFRA_KUBERNETES_PVC_STRATEGY="unique"`

There are two [Persistent Volume Claim](https://docs.openshift.com/container-platform/3.7/dev_guide/persistent_volumes.html) strategies:

* **unique** - each workspace volume gets own PVC.  This is the default strategy. When a workspace is deleted, associated PVC is deleted as well. However, an associated PV may not be recycled and tghus cannot be re-used for a new claim. See [k8s docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recycling). If you have started your cluster with `oc cluster up`, you need to create a service account for a special recycler pod: `oc create serviceaccount pv-recycler-controller -n openshift-infra` (requires admin login)
* **common** - there is one PVC for all workspaces. When a PVC is shared with all workspaces, there's a special service pod that starts before workspace is created to create a subpath in the PV for this particular ws. When a workspace is deleted an associated subpath is deleted as well.

If a common strategy is set, it is impossible to run multiple workspaces simultaneously because of a default `ReadWriteOnce` [access mode](https://docs.openshift.com/container-platform/3.7/architecture/additional_concepts/storage.html#pv-access-modes) for workspace PVCs.

OpenShift cluster admins may want to study docs on [distributed volumes](https://docs.openshift.com/container-platform/3.7/install_config/persistent_storage/index.html) and [applying resource limits](https://docs.openshift.com/container-platform/3.7/admin_guide/quota.html).


## HTTPS Mode

To enable https for server and workspace routes, export the following environment variable:

`ENABLE_SSL=true`

When deploying to OCP, HTTPS is enabled by default.

## Scalability

To be able to run more workspaces, [add more nodes to your OpenShift cluster](https://docs.openshift.com/container-platform/3.7/admin_guide/manage_nodes.html). If the system is out of resources, workspace start will fail with an error message returned from OpenShift (usually it's `no available nodes` kind of error).

## Debug Mode

If you want Che server to run in a debug mode export the following env before running the script (false by default):

`CHE_DEBUG_SERVER=true`

## Image Pull Policy

If you want to always have the latest nightly image or use own latest tags when developing and testing Che

`IMAGE_PULL_POLICY`

## Private Docker Registries

Refer to [OpenShift documentation](https://docs.openshift.com/container-platform/3.7/security/registries.html)

## Enable ssh and sudo

By default, pods are run with an arbitrary user that has a randomly generated UID (the range is defined in OpenShift config file). This security constrain has several consequences for Eclipse Che users:

* installers for language servers will fail since most of them require `sudo`
* no way to run any sudo commands in a running workspace

It is possible to allow root access which in its turn allows running system services and change file/directory [permissions](#filesystem-permissions). You can change this behavior. See [OpenShift Documentation for details](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_scc.html#enable-images-to-run-with-user-in-the-dockerfile).

You may also configure some services to bind to ports below `1024`, say, apache2. Here's an example of enabling it for [Apache2](https://github.com/eclipse/che-dockerfiles/blob/master/recipes/php/Dockerfile#L49) in a PHP image.

**How to Get a Shell in a Pod?**

Since OpenShift routes do not support ssh protocol, once cannot run sshd (or equivalent) in a pod and ssh into it. However, OpenShift itself provides a few alternatives (only for users who can authenticate as a user that has deployed Che):

* `oc rsh ${POD_NAME}` (you can get running pods with `oc`). Note that this is a remote shell, not an ssh connection
* in an OpenShift **web console, projects > ws-namespace > pods > pod details > Terminal**.

Once Che server is able to create OpenShift objects on behalf of a current user, rsh will be available for all users. You may follow GitHub [issue](https://github.com/eclipse/che/issues/8178) to get updates.

## Filesystem Permissions

As said above, pods in OpenShift are started with an arbitrary user with a dynamic UID that is generated for each namespace individually. As a result, a user in an OpenShift pod does not have write permissions for files and directories unless root group (UID - `0`) has write permissions for those (an arbitrary user in OpenShift belongs to root group). All Che ready to go stacks are optimized to run well on OpenShift. See an example from a [base image](https://github.com/eclipse/che-dockerfiles/blob/master/recipes/stack-base/centos/Dockerfile#L45-L48). What happens there is that a root group has write permissions for `/projects` (where workspace projects are located), a user home directory and some other dirs.

## Che Server Logs

When Eclipse Che gets deployed to OpenShift, a PVC `che-data-volume` is [created](https://github.com/eclipse/che/blob/master/dockerfiles/init/modules/openshift/files/scripts/che-openshift.yml#L30) and bound to a PV. Logs are persisted in a PV and can be retrieved in the following ways:

* `oc get log dc/che`
* `oc describe pvc che-data-claim`, find PV it is bound to, then `oc describe pv $pvName`, you will get a local path with logs directory. Be careful with permissions for that directory, since once changed, Che server wont be able to write to a file
* in OpenShift web console, eclipse-che project, **pods > che-pod > logs**.

## Multi-User: Using Own Keycloak and PSQL

Out of the box Che is deployed together with Keycloak and Postgres pods, and all three services are properly configured to be able to communicate. However, it does not matter for Che what Keycloak server and Postgres DB to use, as long as those have compatible versions and meet certain requirements.


***Che Server and Keycloak***

KeyCloak server URL is retrieved from the `CHE_KEYCLOAK_AUTH__SERVER__URL` environment variable. A new installation of Che will use its own Keycloak server running in a Docker container pre-configured to communicate with Che server. Realm and client are mandatory environment variables. By default Keycloak environment variables are:

```
CHE_KEYCLOAK_AUTH__SERVER__URL=http://${KC_ROUTE}:5050/auth
CHE_KEYCLOAK_REALM=che
CHE_KEYCLOAK_CLIENT__ID=che-public
```

You can use your own Keycloak server. Create a new realm and a public client. A few things to keep in mind:

* It must be a public client
* `redirectUris` should be `${CHE_SERVER_ROUTE}/*`. If no or incorrect `redirectUris` are provided or the one used is not in the list of `redirectUris`, Keycloak will display an error saying that redirect_uri param is invalid.
* `webOrigins` should be  either`${CHE_SERVER_ROUTE}` or `*`. If no or incorrect `webOrigins` are provided, Keycloak script won't be injected into a page because of CORS error.


***Using an alternate OIDC provider instead of Keycloak***

Instead using a Keycloak server, Che now provides a limited support for alternate authentication servers compatible with the [OpenId Connect specification](http://openid.net/specs/openid-connect-core-1_0.html).

Some limitations restrict the alternate OIDC providers that can be used with Eclipse Che. Supported providers should:
- implement access tokens as JWT tokens including at least the following claims:
    - `exp`: the expiration time (https://tools.ietf.org/html/rfc7519#section-4.1.4)
    - `sub`: the subject (https://tools.ietf.org/html/rfc7519#section-4.1.2)
- allow redirect Urls with wildcards at the end
- provide an endpoint that returns the [OpenID Provider Configuration information](http://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig). According to the specification, this endpoint should end with sub-path `/.well-known/openid-configuration`.

When using an alternate OIDC provider, the following Keycloak environment variables should be set to `NULL`:

```
CHE_KEYCLOAK_AUTH__SERVER__URL=NULL
CHE_KEYCLOAK_REALM=NULL
```

Instead, you should set the folowing environement variables:

```
CHE_KEYCLOAK_CLIENT__ID=<client id provided by the OIDC provider>
CHE_KEYCLOAK_OIDC__PROVIDER=<base URL of the OIDC provider that provides a configuration endpoint at `/.well-known/openid-configuration` sub-path>
```

If the optional [`nonce` OpenId request parameter](http://openid.net/specs/openid-connect-core-1_0.html#AuthRequest) is not supported, the following environment variable should be added:

```
CHE_KEYCLOAK.USE__NONCE=FALSE
```

***Che Server and PostgreSQL***

Che server uses the below defaults to connect to PostgreSQL to store info related to users, user preferences and workspaces:

```
CHE_JDBC_USERNAME=pgche
CHE_JDBC_PASSWORD=pgchepassword
CHE_JDBC_DATABASE=dbche
CHE_JDBC_URL=jdbc:postgresql://postgres:5432/dbche
CHE_JDBC_DRIVER__CLASS__NAME=org.postgresql.Driver
CHE_JDBC_MAX__TOTAL=20
CHE_JDBC_MAX__IDLE=10
CHE_JDBC_MAX__WAIT__MILLIS=-1
```

Che currently uses version 9.6.


***Keycloak and PostgreSQL***

Database URL, port, database name, user and password are defined as environment variables in Keycloak pod. Defaults are:

```
POSTGRES_PORT_5432_TCP_ADDR=postgres
POSTGRES_PORT_5432_TCP_PORT=5432
POSTGRES_DATABASE=keycloak
POSTGRES_USER=keycloak
POSTGRES_PASSWORD=keycloak
```

## Development Mode

After you have built your [custom assembly][assemblies], execute `build.sh` [script](https://github.com/eclipse/che/tree/master/dockerfiles/che). You can then tag it, either push to MiniShift or a public Docker registry, and reference in your Che deployment as `CHE_IMAGE_REPO` and `CHE_IMAGE_TAG`.

{% include links.html %}
