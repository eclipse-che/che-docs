---
tags: [ "eclipse" , "che" ]
title: Projects
excerpt: ""
layout: docs
permalink: /:categories/projects/
---
{% include base.html %}
You can place any number of projects into a workspace.

Projects are combinations of modules, folders and files. Projects can be mapped 1:1 to a source code repository. If a project is given a type, then {{ site.product_mini_name }} will active plug-ins related to that type. For example, projects with the maven project type will automatically get the Java plug-in, which provides a variety of intellisense for Java projects.

# Modules  
A module is a portion of a project that can have sets of commands run against it where the sub-directory is treated as the root working directory. Modules make it possible to organize a single repository into multiple, independently buildable and runnable units. To create a module, right click on a folder in the IDE explorer tree and select `Create Module`.  You can then execute commands directly against this module.

# Into  
You can step into or out of the project tree. If you step into a folder, that folder will be set as the project tree root and the explorer will redraw itself. All commands are then executed against this folder root.

# Project Type Definition  
Plug-in developers can define their own project types. Since project types trigger certain behaviors within the IDE, the construction of the projects is important to understand.

1. **A project has type.** Project type is defined as one primary type and zero or more mixin types. A primary project type is one where the project is editable, buildable and runnable. A mixin project type defines additional restrictions and behaviors of the project, but by itself cannot be a primary project type. The collection of primary and mixin types for a single project define the aggregate set of attributes that will be stored as meta data within the project.
2. **Project types describe different aspects of a project** such as types of source files inside, the structure of the explorer tree, the way in which a command will be executed, associated workflows, and which plug-ins must be installed.
3. **A project type defines a set of attributes.** The attributes of a project can be mandatory or optional. Attributes that are optional can be dynamically set at runtime or during configuration.
4. **The attributes for a project type can come from multiple locations.** They can be stored within the server’s repository for the project, or sourced from different locations such as source files, build files (pom.xml), or meta-tags. Attribute value providers are abstractions for sourcing these type attributes from different locations.
5. **Attribute value providers allow auto-detection of project type.** They are used during any import to attempt project type auto-detection based upon analysis of the contents of incoming source code. If the filter provided by an Attribute Value Provider generates attributes from source files that match a registered project type, then that type will automatically be assigned to the incoming project.
6. **Project types support multiple inheritance.** A child project type may extend the attribute set of a parent type.
7. **Projects may have parent-child relationships with other projects** in a workspace. Child projects are called modules.
8. **Modules may have different project types than their parents.** Modules may physically exist within the tree structure of the parent (as its subfolders) or outside (the parent is a soft link to the module project).

# Manage Projects Through IDE

#### Create/Import Projects
Projects can be managed by using the IDE with the project explorer and drop down menu at top. New projects can be imported from an remote source such as [Git/SVN]({{base}}{{site.links["ide-git-svn"]}}) or hosted zip file(URL required) with `Workspace > Import Project ...` menu item.  New projects can be created from internal [project samples]({{base}}{{site.links["ws-samples"]}}) with `Workspace > Create Project ..` menu item. 

#### Configure Projects
It is also possible to edit the project's configuration with `Project > Update Project Configuration ...` menu item. Projects type is selected from the list on the left of the project configuration popup window interface. Every project type will have a parent folder, name, and description information associated with it. Depending on the project type selected additional information can be filled in by clicking the `Next` button at bottom pertaining to the particular project type.

#### Project Explorer
![project-tree.png]({{base}}{{site.links["project-tree.png"]}})

On the left side of the IDE, a panel is displaying the project explorer which allow you to browse the sources of your project. You can use your mouse to expand/collapse the folders and packages and right click files/folders to bring up menu options.
<% assign TODO="Add screenshoot che-ide-project-<number>.png" %>

but you are also able to navigate in the project explorer using your keyboard. Use:
- `up arrow` and `down arrow` to navigate in the tree,
- `left arrow` and `right arrow` to expand/collapse folders and packages,
- `enter` to open a file.

<% assign TODO="Need to add additional things that can be done in project explorer like copy" %>

# Manage Projects Through Dashboard
<% assign TODO="The following about impossible to create project into a workspace if the workspace is not running is misleading a little. Editing workspace configuration directly projects can be added with starting workspace. I don't think we need to have it." %>
Projects can also be managed in the dashboard. 
<% assign TODO="We need to add much more about how this is done and link to other documentation that contains more information. Need to add workspace item and dashboard item  to create project instructions. Needs to describe how stacks can be edited to add them manually." %>

# Manage Projects Through API
Projects can be added through the Che's REST API through curl commands. See [projects page]({{base}}{{site.links["server-api-projects"]}}) in `Developers Guide - Rest API` for additional information.
