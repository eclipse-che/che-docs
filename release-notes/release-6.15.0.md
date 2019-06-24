# Eclipse Che 6.15 Release Notes

The Eclipse Che 6.15.0 release contains the following notable features:
 
* **New CORS configuration parameters**: Allowing users to test new CORS configuration before Che 6.16 release
* **Prometheus metrics endpoint**: Allowing to expose HTTP endpoint with different metrics in the Prometheus format
* **More detailed tracing of Workspace operations**: Allowing for more detailed performance monitoring
* **Jaeger deployed in the Helm chart**: Allowing to collect tracing data in Kubernetes environment

---

This release of Eclipse Che comes with significant improvements in monitoring and tracing capabilities for both the Che server and for developer workspaces. There are also a large number of incremental improvements.
---

## Quick Start

Che is a cloud IDE and containerized workspace server - get started on:

* Kubernetes ([single-user](https://www.eclipse.org/che/docs/kubernetes-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/kubernetes-multi-user.html))
* OpenShift ([single-user](https://www.eclipse.org/che/docs/openshift-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/openshift-multi-user.html))
* Docker ([single-user](https://www.eclipse.org/che/docs/docker-single-user.html) or [multi-user](https://www.eclipse.org/che/docs/docker-multi-user.html))
* Try Eclipse Che live at [https://che.openshift.io](https://che.openshift.io)

Learn more in our [documentation](https://www.eclipse.org/che/docs/infra-support.html) and start using a shared Che server or local instance today.

---

# Eclipse Che 6.15 Release Notes

Eclipse Che 6.15 includes:

* **New CORS configuration parameters**: Allowing to test new CORS configuration before Che 6.16 release
* **Prometheus metrics endpoint**: Allowing to expose HTTP endpoint with different metrics in the Prometheus format
* **More detailed tracing of Workspace operations**: Allowing for more detailed performance monitoring
* **Jaeger deployed in the Helm chart**: Allowing to collect tracing data in Kubernetes environment



## Release details

### Adding option to test new CORS configuration, that will be applied in Che 6.16 (https://github.com/eclipse/che/issues/12058)

In Che 6.16 we plan to upgrade Tomcat from 8.5.23 to 8.5.35. This, however, will require us to update our CORS filter configuration for Che WS Master and WS agent, since it would not allow running configuration which is deemed to be unsecure.
More information about the original Tomcat issue is at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

So, this is our planned way of configuring Che CORS filters in Che 6.16
 
- WS Master - CORS Filter disabled
- WS Agent - CORS Filter enabled, allowing requests with credentials, providing Domain of WS Master as an allowed origin

**Before we apply that, we strongly encourage you to test these changes on your Che installation by altering CORS configuration with environment variables, introduced in Che 6.15 release:**

1) use `CHE_CORS_ENABLED=false` environment variable for Che deployment to disable CORS on WS Master.
2) use `CHE_WSAGENT_CORS_ALLOWED__ORIGINS=<wsmaster-domain>` to set the default allowed origin of WS Agent CORS pointing to Domain of WS Master (replace `<wsmaster-domain>` with actual Domain value)
Setting origin for WS Agent would be later done automatically in PR for Upgrading Tomcat.

**If you discover a regression related to this configuration (for example, certain cross-origin requests are not working in your Che installation).
Please reach out to us describing the issues you have, so we may address them before Che 6.16 release.**

Additionally, here is the full list of environment variables, that are introduced in 6.15 for configuring CORS filter (https://github.com/eclipse/che/issues/12058), should you want to try other configurations:
You can use them, to try your own CORS configuration for WS Master (by applying following variables to Che deployment), or WS Agent (by applying them to Che Workspace configuration)

- `CHE_CORS_ENABLED` - if true, enables CORS filter (default "true"). Works only for WS Master.
- `CHE_CORS_ALLOW__CREDENTIALS` - "cors.support.credentials" property for CORS filter (default "true")
- `CHE_CORS_ALLOWED__ORIGINS` - "cors.allowed.origins" property for CORS filter, to define allowed origins for requests (default "*")


### Prometheus metrics endpoint (https://github.com/eclipse/che/pull/11990)
Starting from this release we introduced the ability to expose different metrics in [Prometheus](https://prometheus.io/) format.
This feature is disabled by default. To enable it you can set `CHE_METRICS_ENABLED=true` environment variable for Che deployment.
After that, metrics HTTP server will be exposed on port `8087`. List of available in this release metrics

- ClassLoaderMetrics
- JvmMemoryMetrics Record metrics that report utilization of various memory and buffer pools.
- JvmGcMetrics Record metrics that report a number of statistics related to garbage collection emanating from the MXBean and also adds information about GC causes.
- JvmThreadMetrics
- LogbackMetrics
- FileDescriptorMetrics File descriptor metrics gathered by the JVM.
- ProcessorMetrics Record metrics related to the CPU, gathered by the JVM..
- UptimeMetrics
- FileStoresMeterBinder disk usage metrics
- TomcatMetrics


### More detailed tracing of Workspace operations (https://github.com/eclipse/che/pull/12049)

Since 6.14.0 Che exposes tracing data about REST requests made to workspace master server.
This capability has been greatly enhanced in 6.15.0 which reports detailed information about
the progress of workspace operations, including detailed timings of asynchronous jobs. This enables
the server operators to gain more insight into the performance characteristics of the Che server and
allows for better troubleshooting.
 
The tracing information is **not** emitted by default. You need to specifically enable it by setting
the `CHE_TRACING_ENABLED` environment variable to `true`.

The connection to the Jaeger server and the behavior of the trace collection can be configured
through a number of environment variables:

* `JAEGER_ENDPOINT`: The endpoint to which send the tracing data, e.g. `"http://jaeger-collector:14268/api/traces"`
* `JAEGER_SERVICE_NAME`: The name of the service under which Jaeger will categorize the incoming
data, e.g. `"che-server"`
* `JAEGER_SAMPLER_MANAGER_HOST_PORT`: The connection to Jaeger's sampler manager, e.g. `"jaeger:5778"`
* `JAEGER_SAMPLER_TYPE`: The sampling type `"const"`
* `JAEGER_SAMPLER_PARAM`: The parameter supplied to the sampler, e.g. `"1"`
* `JAEGER_REPORTER_MAX_QUEUE_SIZE`: The maximum size of the queue of the sampled data, e.g. `"10000"`

### Jaeger as part of the Che Helm chart

Che 6.15 adds the support for tracing data collection also to its Helm chart for Kubernetes by 
introducing Jaeger deployment to it.
