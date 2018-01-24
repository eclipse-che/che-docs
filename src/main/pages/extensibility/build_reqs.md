---
title: "Build Requirements"
keywords: java. maven, node, npm
tags: [dev_docs]
sidebar: user_sidebar
permalink: build_reqs.html
folder: extensibility
---
{% include links.html %}

## Build Command

`mvn clean install`

Execute this command in the root of your custom assembly or Che repo. To make your build faster, you may use the following arguments:

`-Dskip-enforce -DskipTests -Dskip-validate-sources -Dfindbugs.skip -DskipIntegrationTests=true -Dmdep.analyze.skip=true`

If you prepare a PR to upstream Che, make sure build is a success with just `mvn clean install` with all the tests and enforcers. If you have enough CPU, you may also add `-Dgwt.compiler.localWorkers=4` so that 4 CPU cores will be used during GWT compilation.

## Pre-Reqs

* JDK 1.8.0_130+
* Maven 3.3.5+
* Go 1.8+

By default, Che is built with docker profile, which means Dashboard is built in a Docker container. You may use a different profile though - `mvn clean install -Pnative` - in that case the following Node.JS version needs to be available:

* Node.JS 5.4+

If your [custom assembly][assemblies] does not bring any changes to Dashboard, [Golang agents](https://github.com/eclipse/che/tree/master/agents) and [bootstrapper](what_are_workspaces.html#bootstrapper), you just need JDK 1.8.0_130+ installed.

At least 2 CPUs and 8GB RAM (recommended) is required.

## Build in Docker

You can use a [dev Docker image](https://github.com/eclipse/che/blob/master/dockerfiles/dev/Dockerfile):

`docker run -ti -v ~/.m2:/home/user/.m2 -v /path/to/che/assembly:/che eclipse/che-dev:nightly sh -c "mvn clean install"`

We recommend mounting Maven repo (`-v ~/.m2:/home/user/.m2`) to persist dependencies and make subsequent builds faster.


## Build in Che

See: [Che in Che quickstart][che_in_che_quickstart]

## Enforcers

There are a few Maven enforcers brought by a parent pom.

**License**

All source file should have expected license. If your build fails because of a missing license, you may run `mvn license:format`

**Dependency Convergence**

Your custom dependencies need to be declared to follow dependency convergence rules in Che (i.e. all dependencies have to be declared either in Che `maven-depmgt-pom` or in a root pom of an assembly).

**Formatting**

See: [Code Style](https://github.com/eclipse/che/wiki/Development-Workflow#code-style)
