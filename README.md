## Eclipse Che documentation

Che docs use Jekyll to convert `.adoc` (AsciiDoc) files into HTML pages. Docs are published at [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

## Build and preview

There is a `run.sh` script in the root of the repo that runs a Docker image, mounts sources, and starts Jekyll. When running locally, docs are available at `localhost:4000`. Jekyll watches for changes in `.adoc` files and re-generates resources, so you can preview changes live.

### Building online
[![Contribute](https://che.openshift.io/factory/resources/factory-contribute.svg)](https://che.openshift.io/f?url=https://github.com/eclipse/che-docs)

### Building natively

To build without using Docker, [install required Jekyll dependencies](https://jekyllrb.com/docs/installation/):

```
# yum install maven ruby ruby-devel @development-tools
```

Then, instead of the `run.sh` script, run Maven directly:

```
$ mvn clean install -Pnative
```

## Adding a new page

In order to add a new page, create an `.adoc` file in `src/main/pages/che-<MAJOR-VERSION>/${subdir}` (substitute `<MAJOR-VERSION>` for either `6` or `7`, depending for which version of Che your content is intended).

If there is no sub-directory that fits a new page, create one. Look at headers in existing pages to make sure the generated HTML page has the expected name, title, and keywords. For example:

```yaml
---
title: "Installing single-user Che on Docker"
keywords: docker, installation
tags: [installation, docker]
sidebar: che_6_docs
permalink: docker-single-user.html
folder: setup
---
```

### Naming

Try to use short names and titles for pages. Use dashes (`-`) in page names (`permalink` in page header).

### Keywords

The search script uses page titles, summary, and keywords to search for relevant results. Make sure your keywords are relevant for the page you add.

### Tags

To add a tag, look at available tags in `src/main/pages/che-<MAJOR-VERSION>/tags` folder. Tags should be also registered in `src/main/_data/tags.yml` - so both a tag in `tags.yml` and a respective tag page should be created.

## Formatting and AsciiDoc syntax

See [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/) for syntax and general help with AsciiDoc.

### Links

To post a link to an internal page, use the following syntax:

```
This is a link:file_name.html[link to an internal page]
```

Do not use `.adoc` in the file name. Also, this file should be referenced in at least one sidebar-definition file in the `src/main/_data/sidebars/` directory.

Links to anchors in internal pages:

```
link:file_name.html#tag[link to an anchor on an internal page]
```

Links to external pages:

```
This is a link:https://github.com[link to an external site]
```

### Images

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

### Special characters

To prevent special characters from being interpreted as formatting mark-up, use pass-through macros. For example, to escape underscores, asterisks, or backticks, use:

```
pass:[VARIABLE_NAME__WITH__UNDERSCORES]
```

## How to get support

* **GitHub issue:** [![New questions](https://img.shields.io/badge/New-question-blue.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/question)
[![New bug](https://img.shields.io/badge/New-bug-red.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/bug)

* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to talk to the community and contributors

## How to contribute

We love pull requests and appreciate contributions that make docs more helpful for users. See the [Contribution guide](https://github.com/eclipse/che#contributing).
