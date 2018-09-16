## Eclipse Che docs

Che docs use Jekyll to convert `.adoc` (AsciiDoc) files into HTML pages. Docs are published at [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

## Build and preview

There is a `run.sh` script in the root of the repo that runs a Docker image, mounts sources, and starts Jekyll. When running locally, docs are available at `localhost:4000`. Jekyll watches for changes in `.adoc` files and re-generates resources, so you can preview changes live.

## Adding a new page

In order to add a new page, create an `.adoc` file in `src/main/pages/${subdir}`. If there is no sub-directory that fits a new page, create one. Take a look at headers in pages to make sure the generated HTML page has the expected name, title, and keywords.

```yaml
---
title: "Single-User&#58 Install on Docker"
keywords: docker, installation
tags: [installation, docker]
sidebar: user_sidebar
permalink: docker-single-user.html
folder: setup
---
```

### Naming

Try to use short names and titles for pages. Use `_` or `-` in page names (`permalink` in page header).

### Keywords

The search script uses page titles, summary, and keywords to search for relevant results. Make sure your keywords are relevant for the page you add.

### Tags

If you need to add a tag, take a look at available tags in `src/main/pages/tags` folder. Tags should be also registered in `src/main/_data/tags.yml` - so both a tag in `tags.yml` and a respective tag page should be created.

## Formatting and AsciiDoc syntax

See [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/) for syntax and general help with AsciiDoc.

### Links

To post a link to an internal page, use the following syntax:

```
This is a link:file_name.html[link text]
```

Do not use `.adoc` in the file name. Also, this file should be referenced in at least one sidebar in the `src/main/_data/sidebars` file.

Links to anchors in internal pages:

```
link:file_name.html#tag[link text]
```

Links to external pages:

```
This is a link:https://github.com[link text]
```

### Images

Images are located in the `src/main/che/docs/images` directory. To publish an image, use the following syntax:

```
image::directory/img.png[]
```

Do not drop images into the root of the `images` directory - either choose an existing sub-dir or create one if none of them fit an image.

Images are sized automatically. You can provide a URL to a full-size image, as well as a caption and alt text:

```
.Click to view a larger image
[link=che/docs/images/devel/js_flow.png
image::devel/js_flow.png[Alt text]
```

Please, do not post too many images unless it is absolutely necessary. Animated `.gif` images are preferred, especially when explaining how to use complex UI features.

### Special characters

To prevent special characters from being interpreted as formatting mark-up, use pass-through macros. For example, to escape underscores, asterisks, or backticks, use:

```
pass:[VARIABLE_NAME__WITH__UNDERSCORES]
```

## How to get support

* **GitHub issue:** open an issue in this repository
* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to discuss with community and contributors

## How to contribute

We love pull requests and appreciate contributions that make docs more helpful for users. See: [Contribution guide](https://github.com/eclipse/che#contributing).
