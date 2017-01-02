# Eclipse Che Docs 
Eclipse Che uses Jekyll 3.3.1 to generate documentation from this reposistory as a static html webpages. 

## Viewing Generated Documentation
Latest shipped release of documentation can viewed at [https://www.eclipse.org/che/docs/](https://www.eclipse.org/che/docs/). 

Nightly documentation of this repository and can be viewed at [https://www.eclipse.org/che/docs-versions/nightly/](https://www.eclipse.org/che/docs-versions/nightly/). 

Other versions are listed/linked at home page of [https://www.eclipse.org/che/docs/](https://www.eclipse.org/che/docs/). 

## Viewing Generated Documentation

This repository houses documentation for Eclipse Che ([repo](https://github.com/eclipse/che) / [site](https://eclipse.com/che/)). Content is held in markdown files in the `/src/main/_docs` directory. Images should be placed in `/src/main/_docs/assets/imgs`.

Docs are built using Jekyll and the output is static HTML that is hosted at [https://eclipse.com/che/docs](https://eclipse.com/che/docs) and in the product at `{che-domain}/docs`.

# Linking to Docs and Images
Because the docs are generated into static HTML linking to docs and images is a bit unusual. We provide a custom plugin [_plugins/links.rb](_plugins/links.rb) to create links.
- Link to a Che docs page "_docs/workspace-administration/ws-agents.md": `[workspace agents]({{base+sites.links["ws-agents"]}})`
  - Link definition `[<link description shown in html>]({{base+sites.links["<file base name>"]}}#<section name>)`
  - `sites.links["<file base name>"]` is a global hash value created by links plugin [_plugins/links.rb](_plugins/links.rb) before html generation.
  - Links plugin uses the following variables in [_config.yml](_config.yml) file:
    - Each `defaults.value.categories` used to create same permalink used in markdown file.
    - Each `collections` used to find file paths for each markdown file specified in [_data](_data) folder.
  - YAML files in [_data](_data) are used to create navigation bar on right of page for related documentation groups.
  - Section of markdown files can be optionally linked by adding `#<section name>` at end.
    - The \<section name\> come from taking section title and making all lower case and replace space with `-`. Ex. `# Creating New Agent` would be `#creating-new-agents`.
- Link to image `/docs/assets/imgs/quick-documentation.png`: `![quick-documentation.png]({{base+sites.links["quick-documentation.png"]}})`

# Naming convention
- Markdown files
    - File base name will always begin with a word, words with `_` seperating them or abbreviation followed by `-`. For example in "_docs/workspace-administration/" folder all markdowns have prefix "ws-" like "ws-agents.md".
- Folders
    - Folders for markdown files should be located under "_docs" folder.
    - Names of folders should contain lowercase a-z characters and `-` to seperate words.
    
# Markdown header
- Each markdown needs [front matter](https://jekyllrb.com/docs/frontmatter/)
    - First line of front matter needs to be `tags: [ "eclipse" , "che" ]`. This is used by jekyll to determine which product documentation is from.
    - Second line needs to be `title: <title>` where `<title>` are words with space and can NOT be enclosed with quotes. Will be displayed at top of generated page.
    - Third line needs to be `excerpt: "<excert>"` where `<excert>` is optional.
    - Fourth line needs to be `layout: <layout>` where `<layout>` matches collections name in [_config.yml](_config.yml) such as "docs", "tutorials" etc.
    - Fifth line needs to be `permalink: /:categories/<subfolder>/` where `<subfolder>` is lowercase a-z characters and `-` to seperate words. Should match `<subfolder>` used by other markdowns in same folder.
- Directly after the [front matter](https://jekyllrb.com/docs/frontmatter/) needs to have `{% include base.html %}` which allows relative paths to be used.

# Building Docs
Docs are built using a Docker image with Jekyll inside it. You will need Docker running on your machine to build the Che docs.

Navigate to the repo "src/main/" on your filesystem and type:

```
$ cd {your-repo-location}/src/main/
$ ./docs.sh --run
```

The Jekyll server will scan for changes to the .md files every 2 seconds and auto-update the generated HTML.

# Getting Help
If you have questions or problems, please create an issue in this repo.
