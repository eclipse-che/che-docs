Table of Contents
=================
* [Code of Conduct of Eclipse Che documentation project](#code-of-conduct-of-eclipse-che-documentation-project)
  * [Our Pledge](#our-pledge)
  * [Our Standards](#our-standards)
  * [Attribution](#attribution)
* [Creating documentation](#creating-documentation)
   * [AsciiDoc Formatting](#asciidoc-formatting)
      * [Using test-adoc for AsciiDoc syntax verification](#using-test-adoc-for-asciidoc-syntax-verification)
   * [Documentation Structure](#documentation-structure)
      * [Using newdoc to create templates for new documents](#using-newdoc-to-create-templates-for-new-documents)
   * [Writing documentation](#writing-documentation)
      * [Style](#style)
      * [Using vale to check the style](#using-vale-to-check-the-style)
      * [Adding Images](#adding-images)
      * [Using special characters](#using-special-characters)
   * [Building Documentation](#building-documentation)
   * [Pull Request Process](#pull-request-process)
   * [Publishing documentation](#publishing-documentation)
* [Getting Support](#getting-support)


## Code of Conduct of Eclipse Che documentation project

### Our Pledge

In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to make participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment
include:

* Using welcoming and inclusive language
* Being respectful of differing viewpoints and experiences
* Gracefully accepting constructive criticism
* Focusing on what is best for the community
* Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

* The use of sexualized language or imagery and unwelcome sexual attention or advances
* Trolling, insulting or derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or electronic address, without explicit permission
* Other conduct which could reasonably be considered inappropriate in a professional setting

### Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 1.4, available at [http://contributor-covenant.org/version/1/4][version]

[homepage]: http://contributor-covenant.org
[version]: http://contributor-covenant.org/version/1/4/

## Contributing to the documentation

### Pull Request process

1. Eclipse Che documentation project follows a forking workflow. To learn more, read [Atlassian Git Tutorial, Forking Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow). Fork the repository and ensure you create all branches in your own fork before you start working.
2. The default publication branch is `master`. Unless your change is intended for a specific version, submit the PR against the `master` branch. 
3. Specify as much information as possible in the PR template. 

### Understanding Che Documentation ecosystem

* Eclipse Che documentation follows the _IBM Style Guide_. If you do not have a paper copy of the styleguide, see the [developerWorks editorial style guide](https://www.ibm.com/developerworks/library/styleguidelines/index.html) on the IBM website. While developerWorks is no longer maintained, it still provides useful reference information. 

* To learn more about the tool validating the style, see the [`vale` documentation](https://errata-ai.gitbook.io/vale/).

* Eclipse Che documentation uses AsciiDoc for markup. To learn more about AsciiDoc syntax, see the [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/).

* The Eclipse Che documentation project follows guidelines from the [Modular Documentation Initiative](https://redhat-documentation.github.io/modular-docs/). As Antora is using the term of _module_ with a different acceptation, this project is refering to them as _topics_. To understand the nature of topics, see the [Appendix A: Modular Documentation Terms and Definitions](https://redhat-documentation.github.io/modular-docs/#modular-docs-terms-definitions).

* Eclipse Che documentation uses Jekyll to build the documentation.

* To learn more about the `newdoc` tool generating the topic templates, see [`newdoc` documentation](https://github.com/redhat-documentation/tools/tree/master/newdoc).

* To learn more about the `test-adoc` tool validating the topic files, see the [`test-adoc` documentation](https://github.com/jhradilek/check-links).

### Editing and building the documentation using Che

To edit the Eclipse Che documentation using Hosted Che:

1. Fork the https://github.com/eclipse/che-docs/ project. See [Fork a repo](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
2. The fork is now accessible at following URL, where `<github-handle>` is your GitHub handle: https://github.com/<github-handle>/che-docs/
2. Create a branch `<branch-name>` for your work.
4. The fork is now accessible at following URL: https://github.com/<github-handle>/che-docs/tree/<branch-name>
5. Use following factory to open the branch in a workspace running on Hosted Che: https://che.openshift.io/factory?url=https://github.com/<github-handle>/che-docs/tree/<branch-name>
6. Open *My Workspace*.
7. Open *User Runtimes / Tools / Generate reference tables*.
8. Open *User Runtimes / Antora / Preview server*.

* To learn more about Hosted Che, see the [Hosted Che documentation](https://www.eclipse.org/che/docs/che-7/hosted-che/).

### Creating a new topic using Che

To create a new topic using a Che workspace:

1. Open *My Workspace*. 
2. Open *User Runtimes / tools / Create a new topic*.
3. Choose the target guide among the available guides:
* `overview`: introductory section
* `end-user-guide`: documentation for developers: navigating dashboard, working in Che-Theia, and so on 
* `installation-guide`: installation guides
* `administration-guide`: documentation for administrators of the clusters: configuring Che on a cluster, managing users, monitoring resources, security and data recovery 
* `contributor-guide`: how to develop plug-ins for Che, add new debuggers, languages, and so on
* `extensions`: documentation about extensions for Che, such as Eclipse Che4z, OpenShift Connector.
4. Choose the topic nature:
* `assembly` 
* `concept`
* `procedure` 
* `reference`
5. Enter the title for the new topic.
6. The file is generated in the `src/main/pages-che-7/<guide_name>/` directory and the script displays related information.

### Validating an asciidoc file using Che

To validate the compliance of an asciidoc file with Modular Documentation standards from a Che workspace:

1. Open *My Workspace*.
2. Open *User Runtimes / tools / Test-adoc*.
2. Enter the relative path of the file to check.
3. The tool `test-adoc` tests the file and produces some output.

### Validating content style using Che

To view `vale` suggestions, from a Che workspace:

* Open the file to check.
* Look at the *Problems* panel in the *Bottom Panel*.
* To toggle the view of this panel use the *View > Problems* menu entry.

### Adding images

Images are located in the `src/main/che/docs/images/` directory. To publish an image, use the following syntax:

```
image::directory/img.png[alt text]
```

Do not add images into the root of the `images/` directory - either choose an existing sub-directory or create one if none of them fits the new image.

Images are sized automatically. You can provide a URL to a full-size image, as well as a caption and alt text:

```
.Click to view a larger image
[link=che/docs/images/devel/js_flow.png
image::devel/js_flow.png[Alt text]
```

Do not post too many images unless it is absolutely necessary. Animated `.gif` images are preferred, especially when explaining how to use complex UI features.

### Using special characters

To prevent special characters from being interpreted as formatting mark-up, use pass-through macros. For example, to escape underscores, asterisks, or backticks, use:

```
pass:[VARIABLE_NAME__WITH__UNDERSCORES]
```

### Building Documentation on a local environment

To build documentation locally:

#### Prerequisites:

* A running installation of `podman` or `docker`.

#### Procedure

1. To build documentation locally, run:
```
$ bash run.sh
```
2. Go to `localhost:4000` in your browser.

### Creating a new topic using a local environment

To create a new topic using a local IDE.

1. Install newdoc and follow the previous procedure:
```
$ pip install --user newdoc
```
2. Run following command:
```
./tools/newtopic.sh
```


### Validating an asciidoc file using a local environment

To validate the compliance of an asciidoc file with Modular Documentation standards on a local environment:

1. Open a `bash` terminal.
2. Run the following command:  
```
$ ./tools/test-adoc.sh <PATH_TO_THE_FILE>
```
3. The tool `test-adoc` tests the file and produces some output.


### Validating content style using a local environment

To run `vale` from a local environment:

1. Install `vale` following the https://errata-ai.gitbook.io/vale/getting-started/installation[Installing `vale` documentation].
2. To run `vale`, execute from the root directory of the project:
```
$ vale <PATH_TO_THE_FILE>"
```

### Validating links using a local environment

To run `linkchecker` from a local environment:

1. Install `linkchecker` following the https://github.com/linkchecker/linkchecker[Installing `linkchecker` documentation].
```
$ pip3 install --user git+https://github.com/linkchecker/linkchecker.git
```
2. To run `vale`, execute from the root directory of the project:
```
$ linkchecker -f linkcheckerrc  http://0.0.0.0:4000/
```


### Publishing documentation

The publication URL of Eclipse Che Documentation is [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

### Getting support

* **GitHub issue:** [![New questions](https://img.shields.io/badge/New-question-blue.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/question)
[![New bug](https://img.shields.io/badge/New-bug-red.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/bug)

* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to talk to the community and contributors.

