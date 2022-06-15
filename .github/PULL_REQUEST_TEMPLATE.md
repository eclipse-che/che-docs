
<!-- 
Please use one of the following prefixes for the title:
docs: Documentation not including procedures. Engineering review is mandatory.
procedures: Documentation including procedures. Testing procedures is mandatory. Engineering and QE review is mandatory (Engineering can review on behalf of QE). 
chore: Routine, release, tooling, version upgrades.
fix: Fix build, language, links, or metadata.
-->

<!-- Read our [Contribution guide](https://github.com/eclipse/che-docs/blob/main/CONTRIBUTING.adoc) before submitting a PR. -->

## What does this pull request change?

## What issues does this pull request fix or reference?

## Specify the version of the product this pull request applies to

## Pull Request checklist

The author and the reviewers validate the content of this pull request with the following checklist, in addition to the [automated tests](code_review_checklist.adoc).

- Any procedure:
  - [ ] Successfully tested.
- Any page or link rename:
  - [ ] The page contains a redirection for the previous URL.
  - Propagate the URL change in:
    - [ ] Dashboard [default branding data](https://github.com/eclipse-che/che-dashboard/blob/main/packages/dashboard-frontend/src/services/bootstrap/branding.constant.ts)
    - [ ] Chectl [constants.ts](https://github.com/che-incubator/chectl/blob/main/src/constants.ts)
- [ ] Builds on [Eclipse Che hosted by Red Hat](https://workspaces.openshift.com).
- [ ] the *`Validate language on files added or modified`* step reports no vale warnings.
