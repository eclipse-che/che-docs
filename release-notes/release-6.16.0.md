## Release summary

Eclipse Che 6.16 includes:

* **Update of the `/activity` REST endpoint**: It is now capable of returning information about
workspace activity.

## Upgrading

Instructions on how to upgrade.


## Release details

### Update of the `/activity` REST endpoint

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
