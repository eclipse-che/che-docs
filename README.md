# che-docs

This repository houses documentation for Eclipse Che ([repo](https://github.com/eclipse/che) / [site](https://eclipse.org/che/)). Content is held in markdown files in the `/src/main/_docs` directory. Images should be placed in `/src/main/assets/imgs`.

Docs are built using Jekyll and the output is static HTML that is hosted at [eclipse.org/che/docs](https://eclipse.org/che/docs) and in the product at `{che-domain}/docs`.

# Linking to Docs and Images
Because the docs are generated into static HTML linking to docs and images is a bit unusual:
- Link to a Che docs page: `[Codenvy Factories]({{base}}/docs/setup/che-setup-docker/index.html)`
  - `{{base}}/docs` is always required
  - `/setup` is the directory where the .md file is in the repo
  - `/che-setup-docker` is the name of the .md file without the .md extension
  - `/index.html` is always required at the end
- Link to a section in a docs page: `[Codenvy Factories]({{base}}/docs/setup/che-setup-docker/index.html#run-the-image)`
  - `#run-the-image` is the section heading name with spaces replaced by dashes
- Link to an image: `![mypic.png]({{base}}/assets/imgs/mypic.png)`

# Building Docs
Docs are built using a Docker image with Jekyll inside it. You will need Docker running on your machine to build the Eclipse Che docs.

Navigate to the repo on your filesystem and type:
```
$ cd {your-repo-location}/src/docs
$ ./docs.sh --run
```
The Jekyll server will scan for changes to the .md files every 2 seconds and auto-update the generated HTML.

# Getting Help
If you have questions or problems, please create an issue in this repo.
