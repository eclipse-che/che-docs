## Release summary

Eclipse Che 6.15 includes:

* **New CORS configuration parameters**: Allowing to test new CORS configuration before Che 6.16 release
* **Prometheus metrics endpoint**: Allowing to expose http endpoint with different metrics in prometheus format

## Upgrading

Instructions on how to upgrade.


## Release details

### Adding option to test new CORS configuration, that will be applied in Che 6.16 (https://github.com/eclipse/che/issues/12058)

In Che 6.16 we plan to upgrade Tomcat from 8.5.23 to 8.5.35. This however will require us to update our CORS filter configuration for Che WS Master and WS agent, since it would not allow running configuration which is deemed to be unsecure.
More information about original Tomcat issue is at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

So, this is our planned way of configuring Che CORS filters in Che 6.16
 
- WS Master - CORS Filter disabled
- WS Agent - CORS Filter enabled, allowing requests with credentials, providing Domain of WS Master as an allowed origin

**Before we apply that, we strongly encourage you to test these changes on your Che installation by altering CORS configuration with environment variables, introduced in Che 6.15 release:**

1) use `CHE_CORS_ENABLED=false` environment variable for Che deployment to disable CORS on WS Master.
2) use `CHE_WSAGENT_CORS_ALLOWED__ORIGINS=<wsmaster-domain>` to set the default allowed origin of WS Agent CORS pointing to Domain of WS Master (replace `<wsmaster-domain>` with actual Domain value)
Setting origin for WS Agent would be later done automatically in PR for Upgrading Tomcat.

**If you discover an regression related to this configuration (for example, certain cross origin requests are not working in your Che installation).
Please reach out to us describing the issues you have, so we may address them before Che 6.16 release.**

Additionally, here is the full list of environment vairables, that are introduced in 6.15 for configuring CORS filter (https://github.com/eclipse/che/issues/12058), should you want to try other configurations:
You can use them, to try your own CORS configuration for WS Master (by applying following variables to Che deployment), or WS Agent (by applying them to Che Workspace configuration)

- `CHE_CORS_ENABLED` - if true, enables CORS filter (default "true"). Works only for WS Master.
- `CHE_CORS_ALLOW__CREDENTIALS` - "cors.support.credentials" property for CORS filter (default "true")
- `CHE_CORS_ALLOWED__ORIGINS` - "cors.allowed.origins" property for CORS filter, to define allowed origins for requests (default "*")


### Prometheus metrics endpoint (https://github.com/eclipse/che/pull/11990)
Starting from this release we introduced the ability to expose different metrics in [Prometheus](https://prometheus.io/) format.
This feature is disabled by default. To enable it you can set `CHE_METRICS_ENABLED=true` environment variable for Che deployment.
After that, metrics HTTP server will be exposed on port `8087`. List of awailable in this release metrics

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

### Feature 2 (#ISSUE)

Feature description focusing on value to the user or contributor.

Learn more in the documentation: [Link to the documentation](<URL>).

## Other notable enhancements

* Issue title. (#ISSUE)

## Notable bug fixes

* Fixed issue’s title. (#ISSUE)

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)
