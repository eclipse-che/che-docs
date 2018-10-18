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

Maven is natively supported by JDT.LS

You can forcefully update dependencies for a Maven project by calling context menu > **Maven > Reimport**.

## Gradle

Gradle is natively supported by JDT.LS.

## NPM

There's no plugin for Che that will automatically run npm install for JS projects. You can, however, author a [custom command][commands-ide-macro] to install dependencies.
