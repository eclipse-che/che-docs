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

## Creating documentation

### AsciiDoc Formatting
Eclipse Che documentation uses AsciiDoc for markup. See [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/) for syntax and general help with AsciiDoc.

#### Using `test-adoc` for AsciiDoc syntax verification
To verify that the syntax of your document is correct, use the [`test-adoc`](https://github.com/jhradilek/check-links) script. 
`test-adoc` is integrated into the `run.sh` script in the root directory of the project.
 
To run `test-adoc`, execute from the root directory of the project: 
```
$ bash run.sh -test-adoc <PATH_TO_THE_FILE>
```

### Documentation Structure
The Eclipse Che documentation project follows guidelines from the [modular documentation initiative](https://redhat-documentation.github.io/modular-docs/). Use templates provided in the [Modular Documentation Reference](https://redhat-documentation.github.io/modular-docs/#creating-modules) to create new user stories.

To add a new page, create a `.adoc` file in `src/main/pages/che-<version>/<directory_name>` 

<b id="f2">Versions: </b>
* `che-6` - Eclipse Che 6 content. Note that Che 6 is deprecated. 
* `che-7` - Eclipse Che 7 content, including y-streams and z-streams.   

<b id="f1">Available directories: </b> 
* `overview` - introductory section
* `end-user-guide` - documentation for developers: navigating dashboard, working in Che-Theia, and so on 
* `installation-guide` - installation guides
* `administration-guide` - documentation for administrators of the clusters: configuring Che on a cluster, managing users, monitoring resources, security and data recovery 
* `contributor-guide` - how to develop plug-ins for Che, add new debuggers, languages, and so on
* `extensions` - documentation about extensions for Che, such as Eclipse Che4z, OpenShift Connector 

#### Using `newdoc` to create templates for new documents

With the [`newdoc`](https://github.com/redhat-documentation/tools/tree/master/newdoc) script, you can generate empty modular templates for your new user story.  
`newdoc` is integrated into a `run.sh` script in the root directory of the project.

To run `newdoc`, execute from the root directory of the project:  
```
$ bash run.sh -newdoc --procedure "Title of your new procedure file"
```

### Writing documentation
#### Style
Eclipse Che documentation follows the IBM Style Guide. If you do not have a paper copy of the styleguide, you can refer to [developerWorks editorial style guide](https://www.ibm.com/developerworks/library/styleguidelines/index.html) on the IBM website. While `developerWorks` is not longer supported, it still provides useful reference information. 

#### Using `vale` to check the style
[`vale`](https://errata-ai.gitbook.io/vale/) is a command-line linter. With `vale`, you can check if the style of your documentation follows [the language rules and recommendations defined in the Eclipse Che documentation project](https://github.com/eclipse/che-docs/tree/master/.ci/vale/styles).

`vale` is integrated into a `run.sh` script in the root directory of the project.

To run `vale`, execute from the root directory of the project:
```
$ bash run.sh -vale <PATH_TO_THE_FILE>"
```

### Adding Images

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

### Building Documentation
There is a `run.sh` script in the root of the repository that runs a Docker image, mounts sources, and starts Jekyll. When running locally, docs are available at `localhost:4000`. Jekyll watches for changes in `.adoc` files and re-generates resources, so you can preview changes live.

1. To build documentation locally, run:
```
$ bash run.sh
```
2. Go to `localhost:4000` in your browser.

### Pull Request Process 

1. Eclipse Che documentation project follows a forking workflow. To learn more, read [Atlassian Git Tutorial, Forking Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow). Fork the repository and ensure you create all branches in your own fork before you start working.
2. `master`  is the default working branch. Unless your change is intended for a specific version, submit the PR against the `master` branch. 
3. Specify as much information as possible in the PR template. 

//### Release branches

### Publishing documentation
Che docs use Jekyll to convert `.adoc` (AsciiDoc) files into HTML pages. Docs are published at [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

### Getting Support

* **GitHub issue:** [![New questions](https://img.shields.io/badge/New-question-blue.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/question)
[![New bug](https://img.shields.io/badge/New-bug-red.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/bug)

* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to talk to the community and contributors.
