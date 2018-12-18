## Release summary

Eclipse Che 6.16 includes:

* **Prometheus and Grafana deployed in the Helm chart**: Allowing to collect and inspect metrics emitted by the Che server

## Upgrading

Instructions on how to upgrade.

## Release details

### Prometheus and Grafana deployed in the Helm chart
Eclipse Che server has been emitting a number of metrics since the release 6.15.0.
To enable their easier visualization the Helm chart of the Che server now also deploys a Prometheus
server configured to scrape Che's metrics and a Grafana server pre-configured with a sample
dashboard visualizing some of those metrics.

To try it out, install Che's Helm chart with `--set global.metricsEnabled=true`. 

## Other notable enhancements

* Issue title. (#ISSUE)

## Notable bug fixes

* Fixed issue’s title. (#ISSUE)

## Community, Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:

* [Contributor Name](<PROFILE_URL>) – [Company Name](<COMPANY_URL>) – (#PR): [PR Title](<PR_URL>)
