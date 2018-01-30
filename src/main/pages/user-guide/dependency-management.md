---
title: "Dependency Management"
keywords: workspace, runtime, project, projects, dependency management, maven, gradle
tags: [workspace, runtime]
sidebar: user_sidebar
permalink: dependency-management.html
folder: user-guide
---

{% include links.html %}


## Maven

Currently Eclipse Che provides Maven plugin that is deployed with a workspace agent and started in a separate JVM. The plugin watches for changes in pom.xml, downloads dependencies that updates project's classpath.

You can forcefully update dependencies for a Maven project by calling context menu > **Maven > Reimport**.

## Gradle

At this moment, there's no Gradle support in Eclipse Che. Of course, you can install Gradle in the image that powers your workspace machine and perform builds, however, dependencies won't be in the classpath, thus they are unavailable for editor code analysis and auto completion.

Gradle support comes with implementation of jtd.ls that natively supports both Maven and Gradle. You are welcome to follow an [epic issue](https://github.com/eclipse/che/issues/6157).

## NPM

Once again, there's no plugin for Che that will automatically run npm install for JS projects. You can, however, author a [custom command][commands-ide-macro] to install dependencies.
