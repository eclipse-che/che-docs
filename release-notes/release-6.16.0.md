# Eclipse Che 6.16 Release Notes

* **Prometheus and Grafana deployed in the Helm chart**: Allowing to collect and inspect metrics emitted by the Che server
* **Upgrade of Tomcat & CORS Configuration**: Changes to default CORS configuration and providing more configuration options
* **Run Eclipse Che over https with a self-signed certificate**
* **Improved REST API endpoint `/activity`**: It is now capable of returning information about
workspace activity.

---

The Eclipse Che community is pleased to announce the 6.16 release with a number of significant improvements. This release brings changes in the configuration of the handling of CORS (Cross-Origin Resource Sharing) and updates to the NodeJS and Java stacks on CentOS. This release contains a total of 61 enhancements or bug fixes.

---

## Quick Start

Che is a cloud IDE and containerized workspace server - get started on:

## Release details

### Prometheus and Grafana deployed in the Helm chart
As part of our ongoing work to ensure that Eclipse Che is easier to monitor and trace, we have been
adding a number of metrics which are tracked since the 6.15.0 release. To make it easier for Che 
admins to visualize these metrics, a Helm deployment of Eclipse Che now also deploys a Prometheus 
server which gathers metrics from Che, and Grafana, a popular visualization project, pre-configured 
with a sample dashboard to visualize these metrics.

To try it out, install Che's Helm chart with `--set global.metricsEnabled=true`. 

### Upgrading Tomcat & CORS configuration (https://github.com/eclipse/che/pull/12144)

In this release, Tomcat  will be upgraded to newest version 8.5.35, alongisde our CORS configuration to be compatible with it.
CORS filters are present in Che to allow requests with origins, that can be different from the origin that the client is loaded on (For example, GWT IDE executing requests from browser to WS Agent, with origin belonging to WS Master domain)

While CORS filter on WS Master would remain, we will also add some more configuration variables to Configure CORS for WS Agent, so it would as flexible in configuraion, as WS Master.

Here is what CORS settings will look like in Che 6.16 by default:

WS Master:

"cors.support.credentials" - "false"
"cors.allowed.origins" - "*"

WS Agent:

"cors.support.credentials" - true
"cors.allowed.origins" - <domain of ws master, will be provided automatically based on CHE_API variable>

Here is the full list of environment variables that will be available in Che 6.16 for overriding of default configuration for CORS on WS Master and WS Agent: 

* `CHE_CORS_ENABLED` = Enabling CORS Filter on WS Master. On by default
* `CHE_CORS_ALLOWED_ORIGINS` = List of allowed origins in requests to WS Master. Default is "*".
* `CHE_CORS_ALLOW_CREDENTIALS` = Allowing requests with credentials to WS Master. Default is "false".

* `CHE_WSAGENT_CORS_ENABLED` = Enabling CORS Filter on WS Agent. 
* `CHE_WSAGENT_CORS_ALLOWED__ORIGINS` = List of allowed origins in requests to WS Agent. If not set, or set to "null", value will be evaluated from CHE_API variable at runtime.
* `CHE_WSAGENT_CORS_ALLOW__CREDENTIALS` = Allowing requests with credentials to WS Agent. Default is "true".

**Pull requests:**
* [Upgrade Tomcat and change default CORS configuration](https://github.com/eclipse/che/pull/12144)

### Run Eclipse Che over https with a self-signed certificate

![Che_on_https](https://www.eclipse.org/che/docs/images/workspaces/chrome_cert.png)

Security is increasingly important for web services, and many Eclipse Che users would like to ensure communication between the Che server and client is encrypted and authenticated. In previous versions, it was not possible to start workspaces in Eclipse Che if your container platform was using a self-signed certificate. In this release, we have added that ability. The Che administrator can enable this feature by creating a secret with the certificate, and configuring the server to ensure that the certificate is used by the Che server.

For more information, see [HTTPS Mode - Self-Signed Certs](https://www.eclipse.org/che/docs/che-6/openshift-config.html#https-mode---self-signed-certs).

Links to PRs:
[https://github.com/eclipse/che/pull/12089](https://github.com/eclipse/che/pull/12089)
* [https://github.com/eclipse/che/pull/12112](https://github.com/eclipse/che/pull/12112)


### Improved REST API endpoint `/activity`

The `/activity` endpoint now accepts `GET` queries for workspace IDs that have been in certain state
for a certain amount of time. This can be used to query the server for workspaces that seem to have
been "stuck" in certain state for some time. The `status` and `threshold` or `minDuration`
query parameters can be used to limit the returned results. `status` is required and chooses the
workspace state to query. When `threshold` is set to a UNIX epoch millisecond time, only workspaces
that have been in the state specified by `status` since before the specified time are returned.
`minDuration` is a different way of specifying such threshold by supplying the minimum duration
that the workspace must have been in (before "now") in the given state. If neither `threshold`
nor `minDuration` is specified, the query returns the workspaces that are in given state at the
moment (i.e. as if `threshold` was set to the current time). 

For example, query `GET /activity?status=STARTING&minDuration=300000` would return workspaces
that have been starting for at least 5 minutes (and still are).

This information is available only to users with a new `monitorSystem` permission. In the multiuser
Che installation, this new permission needs to be granted to the users that should be able to access
this information.

