[![Workspace](https://codenvy.io/factory/resources/codenvy-contribute.svg)](https://codenvy.io/f?name=che-codenvy-docs&user=jdrummond)


# Eclipse Che Docs 
Eclipse Che uses Jekyll 3.3.1 to generate documentation from this reposistory as a static html webpages. 

This repository houses documentation for Eclipse Che ([repo](https://github.com/eclipse/che) / [site](https://eclipse.com/che/)). Content is held in markdown files in [/src/main/_docs](https://github.com/codenvy/che-docs/tree/master/src/main/_docs). Images should be placed in [/src/main/_docs/assets/imgs](https://github.com/codenvy/che-docs/tree/master/src/main/_docs/assets/imgs).

Docs are built using Jekyll and the output is static HTML that is hosted at [https://eclipse.com/che/docs](https://eclipse.com/che/docs) and in the product at `{che-domain}/docs`.

### Viewing Generated Documentation
- Documentation for the latest release: [https://www.eclipse.org/che/docs/](https://www.eclipse.org/che/docs/)
- Documentation for nightly builds: [https://www.eclipse.org/che/docs-versions/nightly/](https://www.eclipse.org/che/docs-versions/nightly/)

# Editing Docs
[![Workspace](https://codenvy.io/factory/resources/codenvy-contribute.svg)](https://codenvy.io/f?name=che-codenvy-docs&user=jdrummond)
  
Get a workspace on `codenvy.io` which include all dependencies to edit and preview your changes by clicking on the image above.

# Linking to Docs and Images
Because the docs are generated into static HTML linking to docs and images is a bit unusual. We provide a custom plugin [_plugins/links.rb](_plugins/links.rb) to create links.

### Linking to a Page
A link is defined as: `[<link description shown in html>]({{base}}{{sites.links["<file base name>"]}}#<section name>)`. For example to link to "_docs/workspace-administration/ws-agents.md" you would add the following to your MD:
```
[workspace agents]({{base}}{{sites.links["ws-agents"]}})
```
To link to a subsection of a markdown file add `#<section name>` at end of the link. The section name is the header text with spaces replaced by `-`. For example, the heading `# Creating New Agent` would be linked as `#creating-new-agents`.

### Linking to an Image
To add a link to `/docs/assets/imgs/quick-documentation.png` into your MD you can use: `![quick-documentation.png]({{base}}{{sites.links["quick-documentation.png"]}})`

### Understanding the Links Plugin
The links plugin uses the following variables in [_config.yml](https://github.com/codenvy/che-docs/blob/master/src/main/_config.yml) file:
    - Each `defaults.value.categories` is used to create the permalink used in a markdown file.
    - Each `collections` is used to find file paths for each markdown file specified in the [_data](https://github.com/codenvy/che-docs/tree/master/src/main/_data) folder.
  - YAML files in [_data](https://github.com/codenvy/che-docs/tree/master/src/main/_data) are used to create the navigation bar on the right side of page.

# Naming Conventions
### Adding a New Markdown File
The file name must always begin with a prefix for the section it is part of. See other pages in the section you are adding to for the prefix to be used.

All new files need to have the same [front matter](https://jekyllrb.com/docs/frontmatter/) information at the top of the MD file:
```markdown
---
tags: [ "eclipse" , "che" ]         // Do not change
title: Chefile                      // Your title, do not use quotation marks
excerpt: "Che for your repo."       // Optional short summary
layout: docs                        // Should use `docs` or `tutorial`
permalink: /:categories/chefiles/   // Should match the other files in the folder
---
{% include base.html %}             // Do not change, allows relative paths to work
```
Your content can start after this.

### Adding a New Section
New sections are represented as folders in https://github.com/codenvy/che-docs/tree/master/src/main/_docs. Folder names must contain lowercase a-z characters and `-` to seperate words.
    
# Building Docs
Docs are built using a Docker image with Jekyll inside it. You need Docker and Bash installed to build and host the Che docs.

You can use codenvy.io factory to easily compile and view documentation. Just click [here](https://codenvy.io/f?name=che-codenvy-docs&user=jdrummond).

You can also use the following locally.

```
$ git clone http://github.com/eclipse/che-docs
$ cd che-docs/src/main/
$ bash docs.sh --run

# Markdown converted to static HTML and launches Jekyll server at http://localhost:9080
```

The Jekyll server will scan for changes to the `.md` files every 2 seconds and auto-update the generated HTML.

# Getting Help
If you have questions or problems, please create an issue in this repo.
