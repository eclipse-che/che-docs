## Release summary

Eclipse Che 6.17 includes:

* **Improvements to workspace monitoring metrics**: Added a Prometheus metric to count the number of
workspace failures


## Upgrading

Instructions on how to upgrade.


## Release details

### Improvements to workspace monitoring metrics

As part of the improvements in the monitoring and tracing of workspaces, we have added several new
metrics in this release. The Prometheus metrics exposed by the Che server now include the 
`che_workspace_status` and `che_workspace_failure_total` metrics, allowing users to track the count
of workspaces per status (`STARTING`, `RUNNING` `STOPPING` or `STOPPED`), and the total number of
failed workspaces. Server operators can see when workspaces are failing by using a `while` tag,
which recognizes `STARTING`, `RUNNING` or `STOPPING` values respectively. These new metrics enable
operators to proactively identify when there are issues with workspaces.

## Other notable enhancements

* Issue title. (#ISSUE)

## Notable bug fixes

* Fixed issue’s title. (#ISSUE)

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)
