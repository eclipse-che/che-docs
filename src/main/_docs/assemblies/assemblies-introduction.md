---
tags: [ "eclipse" , "che" ]
title: Introduction
excerpt: ""
layout: docs
permalink: /:categories/intro/
---
{% include base.html %}
An assembly is a customization of Eclipse Che with your own extensions, plugins and branding elements. You can add support for new programming languages, IDE tools, agents for managing workspaces, or even modify the core infrastructure which structures how Che manages workspaces.

Che is commonly extended in three ways: the browser IDE, the Che Server, or a workspace agent:

1. The browser IDE can be extended with new features such as actions, editors, views, or syntax highlighting. Some of these extensions will run entirely within the browser and others may make use of services available over an API running inside the Che server or within a workspace. In other words, your browser extensions can interact and control functions that are running on the server or inside of a workspace.

2. The Che Server can be extended by new plugins. Plugins expose their services through RESTful APIs that are then accessible by the browser IDE. Some capabilities, like project types, are done on the server. Server plugins can also access a workspace to access files, projects or control the Docker container of the workspace.

3. A user's workspace can be extended to provide new APIs inside of agents to be used by the Che server or the browser IDE.
![image05.png]({{ base }}/docs/assets/imgs/image05.png)  

We do not organize the documentation by component, but instead by types of customizations. You will oftne add a new capability to Che that requires server and client side extensions, so a single custom assembly may have multiple plugins that collectively are required for the distributed system to properly operate.

Technically, client and server extensions are different components, however, they can be organized a single plugin with several sub-components.

We provide a custom assembly generator. We find that it's easier for you to get started building custom assemblies by starting with functional ones and then adding new customizations or further excluding core modules available within Che.

We have a number of different archetypes, which are flavors of custom assemblies that you can generate. Each archetype generates a custom assembly that highlights one aspect of configuring Che, whether it is branding, IDE extensions, agents, and so on.

Our examples are usually part of a common broader example: an implementation of adding JSON language support to Eclipse Che. This includes a custom language server packaged as an agent, editor extensions to provide JSON validation, a new file type with an icon, syntax highlighting, and suggestions for auto completion which are sourced from a workspace agent. The completed source code for the sample plugin is [located in GitHub](https://github.com/eclipse/che/tree/master/samples/sample-plugin-json), but you will get more value from generating various custom assemblies with our generator.

# Terminology
[Archetype]({{base}}{{site.links["assemblies-archetype"]}}): An archetype is a maven technique for generating code templates. A single archetype has an ID and generates a complete custom assembly. Differnent archetypes generate assemblies with different types of customizations. We make each archetype customize the minimal number of features to make learning about customizations simpler.

[Assembly]({{base}}{{site.links["assemblies-assembly-lifecycle"]}}): A new packaging of Che or Codenvy that includes plugins, custom branding, and custom installation utilities. A custom assembly is composed of "standard assemblies", which are the individually deployable elements of the distributed system.

**Standard Assembly**
: Individual packages of things that are deployed as part of the distributed system. For example, the IDE is a standard assembly that is deployed as JavaScript and the workspace agent is another standard assembly that is deployed inside of a user's workspace.

[Plugin]({{base}}{{site.links["assemblies-plugin-lifecycle"]}}): A packaging of extensions that will be compiled into a custom assembly. Each standard assembly can have multiple plugins, such as a workspace agent having plugins for git and file management. A plugin is also composed of one or more extensions, which are the code elements that make up the plugin.

**Extension**
: The code that makes up a plugin. Depending upon where extensions will be packaged, their code is in different languages. For example, IDE plugins are authored in Java and JavaScript. However, workspace agents can be authored in Java, Go, or other languages.

# Next Steps
The [assembly lifecycle page]({{base}}{{site.links["assemblies-assembly-lifecycle"]}}) outlines how assemblies and archetypes work and how to get started building them.
