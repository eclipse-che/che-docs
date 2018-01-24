## Eclipse Che Docs

Che docs use Jekyll to convert `.md` files into html page. Docs are published at [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

## Build and Preview

There's `run.sh` script in the root of the repo that runs a Docker image, mounts sources and starts Jekyll. When running locally, docs are available at `localhost:4000`. Jekyll watches for changes in `.md` files and re-generates resources, so you can preview changes live.

## Adding a New Page

In order to add a new page, create `.md` file in `src/main/pages/${subdir}`. If there's no sub-directory that fits a new page, create one. Take a look at headers in pages to make sure the generated html page has expected name, title and keywords.

```yaml
---
title: "Single-User&#58 Install on Docker"
keywords: docker, installation
tags: [installation, docker]
sidebar: user_sidebar
permalink: docker.html
folder: setup
---
{% include links.html %}
```

`{% include links.html %}` is mandatory to enable [links to other pages](#links).

### Naming

Try to use short names and titles for pages. Use `_` or `-` in page names (`permalink` in page header).

### Keywords

Search script uses page titles, summary and keywords to search for relevant results. Make sure your keywords are relevant for the page you add.

### Tags

If you need to add a tag, take a look at available tags in `src/main/pages/tags` folder. Tags should be also registered in `src/main/_data/tags.yml` - so both a tag in `tags.yml` and a respective tag page should be created.

## Links

To post a link to an internal page, use the following syntax:

```
This is a [link][file_name]
```

Do not use `.md` or `.html`. Also, this file should be referenced in at least one sidebar `src/main/_data/sidebars`

Links to anchors in internal pages:

```
This is a [link](file_name.html#tag)
```

Links to external pages:

```
This is a [link](https://github.com)
```

## Images

Images are located in `src/main/images`

To publish an image, use the following syntax

```
{% include image.html file="dir/img.png" %}
```
Do not drop images into the root of `images` directory - either choose an existing sub-dir or create one if none of them fit an image.

Images are sized automatically. You can provide a URL to a full size image, as well as a caption:

```
{% include image.html file="devel/js_flow.png" url="images/devel/js_flow.png" caption="Click to view a larger image" %}
```

Please, do not post too many images unless it is absolutely necessary. Animated `.gif` images are preferred, especially when explaining how to use complex UI features.

## How to Get Support

* **GitHub issue:** open an issue in this repository
* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to discuss with community and contributors

## How to Contribute

We love pull requests and appreciate contributions that make docs more helpful for users. See: [Contribution guide](https://github.com/eclipse/che#contributing).
