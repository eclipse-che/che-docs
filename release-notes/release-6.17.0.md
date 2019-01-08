## Release summary

Eclipse Che 6.17 includes:

* **Workspace failure count metric**: Prometheus metric counting the number of workspace failures


## Upgrading

Instructions on how to upgrade.


## Release details

### Workspace failure count metric

The Prometheus metrics exposed by the Che server now include the `che_workspace_failure_total` 
metric which reports the count of workspaces that failed while in different statuses. You can
distinguish between failures during startup, runtime or shutdown of a workspace using the `while`
tag of the metric, which recognizes `STARTING`, `RUNNING` or `STOPPING` values respectively.
 
## Other notable enhancements

* Issue title. (#ISSUE)

## Notable bug fixes

* Fixed issue’s title. (#ISSUE)

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)
