## Release summary

Eclipse Che 6.17 includes:

* **Workspace counts per status as metrics**: Allowing to monitor the workspace statuses with Prometheus-based tooling


## Upgrading

Instructions on how to upgrade.


## Release details

### Workspace counts per status as metrics

The Prometheus metrics exposed by the Che server now include the `che_workspace_status` metric which
reports the count of workspaces per status (STARTING, RUNNING, STOPPING, STOPPED, each exposed as
a tag of the metric). This enables the server operators to inspect and react to the changes in
the status of the workspaces.
 
## Other notable enhancements

* Issue title. (#ISSUE)

## Notable bug fixes

* Fixed issue’s title. (#ISSUE)

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)
