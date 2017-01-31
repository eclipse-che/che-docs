---
tags: [ "eclipse" , "che" ]
title: Composer
excerpt: ""
layout: tutorials
permalink: /:categories/composer/
---
{% include base.html %}
[Composer](https://getcomposer.org/) is a tool for dependency management in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you.

# 1. Import a Composer Project

Open the `Workspace > Import Project...` wizard from the main menu. Enter the URL for the source code management system, e.g. Git.
A project name will be suggested automatically.

![php.png]({{base}}{{site.links["composer-project-import.png"]}})

Click the `Import` button. The project's source will be downloaded into the workspace.

When done, the wizard will switch to the `Project Configuration` page. Select the `Composer` project type.

![php.png]({{base}}{{site.links["composer-project-config.png"]}})

Click the `Save` button. The Composer dependencies will be installed automatically. 

Look at the Composer console panel for the output of the Composer process.

![php.png]({{base}}{{site.links["composer-output.png"]}})

# 2. Create a PHP Project from Composer Package

Open the `Workspace > Create Project...` wizard from the main menu. Enter a project name.

![php.png]({{base}}{{site.links["composer-project-create.png"]}})

Click the `Next` button. The wizard will switch to the `Composer Package Information` page.

Enter the name of the desired package to create the project from, e.g. `laravel/laravel`.

![php.png]({{base}}{{site.links["composer-project-package.png"]}})

Click the `Create` button. The project's source will be downloaded from [Packagist](https://packagist.org/) and the Composer dependencies will be installed automatically. The output of the Composer process can be seen in the Composer console panel.

# 3. Edit the composer.json File

Double-click on the project's composer.json file to open it in the JSON editor.

The JSON editor provides [IntelliSense]({{base}}{{site.links["ide-intellisense"]}}) based on the [composer.json schema](https://getcomposer.org/doc/04-schema.md).

![php.png]({{base}}{{site.links["composer-editor-intellisense.png"]}})

# 4. Execute Composer Commands

The Composer tool is globally available in the PHP stack. So it is easy to execute Composer commands directly from the Terminal panel.

Visit the Composer documentation for the [command reference](https://getcomposer.org/doc/03-cli.md).

![php.png]({{base}}{{site.links["composer-terminal.png"]}})



