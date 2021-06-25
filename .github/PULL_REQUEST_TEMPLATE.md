# Add here a title for your PR

<!-- 
Please use one of the following prefixes for the title:
docs: Documentation not including procedures. Engineering review is mandatory.
procedures: Documentation including procedures. Testing procedures is mandatory. Engineering and QE review is mandatory (Engineering can review on behalf of QE). 
chore: Choreography, release, tooling, version upgrades.
fix: Fix build, language, links, or metadata.
-->

<!-- Read our [Contribution guide](https://github.com/eclipse/che-docs/blob/master/CONTRIBUTING.adoc) before submitting a PR. -->

## What does this PR do?

## What issues does this PR fix or reference?

## Specify the version of the product this PR applies to

## Pull Request Checklist for committers and reviewers

The content of this Pull Request is compliant with this checklist:

### Level 1 (automated tests blocking PR merge)

- [ ] *`Build and validate PR / link checker (pull_request)`* is successful
  - [ ] *`Build using Antora`* step is successful: documentation is building without warnings, and all AsciiDoc attributes have a definition.
  - [ ] *`Validate links using htmltest`* step is successful: internal and external links are valid.
  - [ ] *`Validate language on files added or modified`* step is successful and reports no vale errors: basic language validation, no major deviations from [IBM Style Guide](https://www.oreilly.com/library/view/the-ibm-style/9780132118989/), [Red Hat Supplementary Style Guide for product documentation](https://redhat-documentation.github.io/supplementary-style-guide/), and project specific language rules.
- [ ] *`eclipsefdn/eca`*  is successful: all contributors have signed the Eclipse Contributor Agreement  (ECA).

### Level 2

- [ ] Any procedure:
  - [ ] Successfully tested.
  - [ ] Describes a scenario already covered by QE tests, otherwise Che QE team has acknowledged an issue.
- [ ] Any page or link rename:
  - [ ] The page contains a redirection for the previous URL.
  - [ ] Propagate the URL change in:
    - [ ] Dashboard [default branding data](https://github.com/eclipse-che/che-dashboard/blob/main/src/services/bootstrap/branding.constant.ts)
    - [ ] Chectl [constants.ts](https://github.com/che-incubator/chectl/blob/master/src/constants.ts)
- [ ] *`Build and validate PR / link checker (pull_request)`* reports no warnings.
  - [ ] *`Validate language on files added or modified`* step reports no vale warnings.
- [ ] Content is appropriate for the intended audience.
- [ ] Effective titles.
- [ ] Information is clear and concise, no ambiguity.
- [ ] No sentences with low information value.
- [ ] Sequence of information is logical.

### Level 3

- [ ] Builds locally, and the output looks fine.
- [ ] Consistent with the rest of the docs.
- [ ] Downstream friendly: correct use of attributes, `ifdef` statements, examples.
- [ ] Follows modularization guidelines. See: [Modular Documentation Reference Guide](https://redhat-documentation.github.io/modular-docs/).
- [ ] Follows the principles of minimalism. See: [The Wisdom of Crowds slides](https://docs.google.com/presentation/d/1Yeql9FrRBgKU-QlRU-nblPJ9pfZKgoKcU8SW6SQ_UqI/edit#slide=id.g1f4790d380_2_257), [The Wisdom of Crowds video](https://youtu.be/s3Em8QSXyn8), [Chunking](https://www.nngroup.com/articles/chunking/).
- [ ] Language is compliant with [IBM Style Guide](https://www.oreilly.com/library/view/the-ibm-style/9780132118989/) and [Supplementary Style Guide](https://redhat-documentation.github.io/supplementary-style-guide/) rules not implemented in vale.
- [ ] Uses screenshot and other visuals when required.
- [ ] Uses verification steps when necessary.
