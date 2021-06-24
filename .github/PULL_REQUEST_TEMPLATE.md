> Read our [Contribution guide](https://github.com/eclipse/che-docs/blob/master/CONTRIBUTING.adoc) before submitting a PR.

### What does this PR do?


### What issues does this PR fix or reference?


### Specify the version of the product this PR applies to.


### Pull Request Checklist for committers and reviewers

The content of this Pull Request is compliant with this checklist:

#### Level 1

- [ ] The *eclipsefdn/eca*  chek is successful: all contributor have signed the Eclipse ECA.
- [ ] *Build and validate PR / link checker (pull_request)* check is successful

    - [ ] *Build using antora* step is successful: eocumentation is building without warnings and all AsciiDoc attributes are defined.
    - [ ] *Validate links using htmltest* step is successful: internal and external links are valid.
    - [ ] *Validate language on files added or modified* step is successful and reports no vale errors: basic language validation, no major infringements against [IBM Style Guide](https://www.oreilly.com/library/view/the-ibm-style/9780132118989/), [Red Hat Supplementary Style Guide for product documentation](https://redhat-documentation.github.io/supplementary-style-guide/), and project specific language rules.

- [ ] Documentation describes a scenario that is already covered by QE tests, otherwise an issue has been created and acknowledged by Che QE team
- [ ] Changed article references are updated where they are used (or a redirect has been configured on the docs side):
    - [ ] Dashboard [default branding data](https://github.com/eclipse-che/che-dashboard/blob/main/src/services/bootstrap/branding.constant.ts)
    - [ ] Chectl [constants.ts](https://github.com/che-incubator/chectl/blob/master/src/constants.ts)

#### Level 2

- [ ] *Build and validate PR / link checker (pull_request)* check reports no warnings.
    - [ ] *Validate language on files added or modified* step reports no vale warnings.
- [ ] Effective titles.
- [ ] Content is appropriate for the intended audience.
- [ ] Sequence of information is logical.
- [ ] Information is clear and concise, no ambiguity.
- [ ] No sentences with low information value.

#### Level 3 

- [ ] Procedure successfully executed.
- [ ] Language compliant with [IBM Style Guide](https://www.oreilly.com/library/view/the-ibm-style/9780132118989/) and [Supplementary Style Guide](https://redhat-documentation.github.io/supplementary-style-guide/) rules not implemented in vale.
- [ ] Follows modularization guidelines. See: [Modular Documentation Reference Guide](https://redhat-documentation.github.io/modular-docs/).
- [ ] Follows the principles of minimalism. See: [The Wisdom of Crowds slides](https://docs.google.com/presentation/d/1Yeql9FrRBgKU-QlRU-nblPJ9pfZKgoKcU8SW6SQ_UqI/edit#slide=id.g1f4790d380_2_257), [The Wisdom of Crowds video](https://youtu.be/s3Em8QSXyn8), [Chunking](https://www.nngroup.com/articles/chunking/).
- [ ] Consistency with the rest of the docs.
- [ ] Downstreaming is considered. (correct use of attributes, ifdef statements, examples)
- [ ] Uses screenshot and other visuals where required.
- [ ] Uses verification steps when necessary.
- [ ] Builds locally, and the output looks fine.
