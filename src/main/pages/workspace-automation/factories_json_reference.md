---
title: "Factories JSON Reference"
keywords: chedir, factories
tags: [chedir, factories]
sidebar: user_sidebar
permalink: factories_json_reference.html
folder: workspace-automation
---

{% include links.html %}

## Overview

A Factory configuration is a JSON snippet either stored within {{ site.product_mini_name }} or as a `.factory.json` file. You can create Factories within the IDE using our URL syntax, within the dashboard, or on the command line with the API and CLI.

```json  
factory : {
  "v"         : 4.0,   // Version of configuration format
  "workspace" : {},    // Identical to workspace:{} object for Eclipse Che
  "policies"  : {},    // (Optional) Restrictions that limit behaviors
  "ide"       : {},    // (Optional) Trigger IDE UI actions tied to workspace events
  "creator"   : {},    // (Optional) Identifying information of author
}
```

The `factory.workspace` is identical to the `workspace:{}` object for Eclipse Che and contains the structure of the workspace. Learn more about [the workspace JSON object][workspace-data-model].

You can export {{ site.product_mini_name }} workspaces and then reuse the workspace definition within a Factory. {{ site.product_mini_name }} workspaces are composed of:
- 0..n projects
- 0..n environments which contain machines to run the code
- 0..n commands to execute against the code and machines
- a type

The `factory.policies`, `factory.ide` and `factory.creator` objects are unique to Factories. They provide meta information to the automation engine that alter the presentation of the Factory URL or the behavior of the provisioning.

## Mixins

A mixin adds additional behaviors to a project as a set of new project type attributes.  Mixins are reusable across any project type. You define the mixins to add to a project by specifying an array of strings, with each string containing the identifier for the mixin.  For example, `"mixins" : [ "pullrequest" ]`.

| Mixin ID   | Description
| --- | ---
| `pullrequest`  | Enables pull request workflow where {{ site.product_mini_name }} handles local & remote branching, forking, and pull request issuance. Pull requests generated from within {{ site.product_mini_name }} have another Factory placed into the comments of pull requests that a PR reviewer can consume. Adds contribution panel to the IDE. If this mixin is set, then it uses attribute values for `project.attributes.local_branch` and `project.attributes.contribute_to_branch`. <br><br> The `pullrequest` mixin requires additional configuration from the `attributes` object of the project.  If present, {{ site.product_mini_name }} will use the project attributes as defined in the Factory. If not provided, {{ site.product_mini_name }} will set defaults for the attributes. <br><br> Learn more about other [mixins][TODO: link to project API docs]

## Pull Request Mixin Attributes
Project attributes alter the behavior of the IDE or workspace.

Different Eclipse Che and Codenvy plug-ins can add their own attributes to affect the behavior for the system.  Attribute configuration is always optional and if not provided within a Factory definition, the system will set itself.

| Attribute   | Description
| --- | ---
| `local_branch` | Used in conjunction with the `pullrequest` mixin. If provided, the local branch for the project is set with this value. If not provided, then the local branch is set with the value of `project.source.parameters.branch` (the name of the branch from the remote).  If `local_branch` and `project.source.parameters.branch` are both not provided, then the local branch is set to the name of the checked out branch.
| `contribute_to_branch` | Name of the branch that a pull request will be contributed to. Default is the value of `project.source.parameters.branch`, which is the name of the branch this project was cloned from.

<br>
Here is a snippet that demonstrates full configuration of the contribution mixin.

```json  
factory.workspace.project : {
  "mixins"     : [ "pullrequest" ],

  "attributes" : {
    "local_branch"         : [ "timing" ],
    "contribute_to_branch" : [ "master" ]
  },

  "source" : {
    "type"       : "git",
    "location"   : "https://github.com/codenvy/che.git",
    "parameters" : {
      "keepVcs" : "true"
    }
  }
}
```


## Policies

```json  
factory.policies : {
  "referer"   : STRING,               // Works only for clients from referer
  "since"     : EPOCHTIME,            // Factory works only after this date
  "until"     : EPOCHTIME,            // Factory works only before this date
  "create"    : [perClick | perUser]  // Create one workpace per click, user or account
}
```

## Limitations
You can use `since : EPOCHTIME`, `until : EPOCHTIME` and `referer` as a way to prevent the Factory from executing under certain conditions.  `since` and `until` represent a valid time window that will allow the Factory to activate. The `referer` will check the hostname of the acceptor and only allow the Factory to execute if there is a match.

## Multiplicity
If `create : perClick` is used, then every click of the Factory URL will generate a new workspace, each with its own identifier, name and resources.  If `create : perUser` is used, then only one workspace will be generated for each unique user that clicks on the Factory URL. If the workspace has previously been generated, we will reopen the existing workspace.

## IDE Customization

```json  
factory.ide.{event} : {          // event = onAppLoaded, onProjectsLoaded, onAppClosed
  "actions" : [{}]               // List of IDE actions to execute when event triggered
}

factory.ide.{event}.actions : [{
  "id"         : String,         // Action for IDE to perform when event triggered
  properties : {}                // Properties to customize action behavior
}]
```
You can instruct the Factory to invoke a series of IDE actions based upon events in the lifecycle of the workspace.

`onAppLoaded`  
: Triggered when the IDE is loaded.

`onProjectsLoaded`  
: Triggered when the workspace and all projects have been activated/imported.

`onAppClosed`  
: Triggered when the IDE is closed.

This is an example that associates a variety of actions with all of the events.

```json  
"ide" : {  
  "onProjectsLoaded" : {                // Actions triggered when a project is opened
    "actions" : [{  
      "id" : "openFile",                // Opens a file in editor. Can add multiple
      "properties" : {                  // The file to open (include project name)
        "file" : "/my-project/pom.xml"
      }
    },
    {  
      "id" : "runCommand",              // Launch command after IDE opens
      "properties" : {
        "name" : "MCI"                  // Command name
      }
    }
  ]},
  "onAppLoaded": {
     "actions": [
        {
           "properties:{
              "greetingTitle": "Getting Started",			// Title of a Welcome tab
              "greetingContentUrl": "http://example.com/README.html"	// HTML to be loaded into a tab
           },
           "id": "openWelcomePage"
        }
     ]
  },
  "onAppClosed" : {                     // Actions to be triggered when IDE is closed
    "actions" : [{
      "id" : "warnOnClose"              // Show warning when closing browser tab
    }]
  }
}
```
Each event type has a set of actions that can be triggered. There is no ordering of actions executed when you provide a list; {{ site.product_mini_name }} will asynchronously invoke multiple actions if appropriate. Some actions can be configured in how they perform and will have an associated `properties : {}` object.

**onProjectsLoaded Event**

| Action   | Properties?   | Description
| --- | --- | ---
| `runCommand`   | Yes   | Specify the name of the command to invoke after the IDE is loaded. Specify the commands in the `factory.workspace.commands : []` array.
| `openFile`   | Yes   | Open project files as a tab in the editor.

**onAppLoaded Event**

| Action   | Properties?   | Description
| --- | --- | ---
| `openWelcomePage`   | Yes   | Customize the content of the welcome panel when the workspace is loaded. Note that browsers block http resources that are loaded into https pages.

**onAppClosed Event**

| Action   | Properties?   | Description
| --- | --- | ---
| `warnOnClose`   | No   | Opens a warning popup when the user closes the browser tab with a project that has uncommitted changes. Requires `project.parameters.keepVcs` to be `true`.

## Action: Open File

This action will open a file as a tab in the editor. You can provide this action multiple times to have multiple files open. The file property is a relative reference to a file in the project’s source tree. The `file` parameter is the relative path within the workspace to the file that should be opened by the editor. The `line` parameter is optional and can be used to move the editor cursor to a specific line when the file is opened. Note that projects are located in the workspaces `/projects` folder.

```json  
{  
  "id" : "openFile",
    "properties" : {
      "file" : "/my-project/pom.xml",
      "line" : "50"
  }
}
```

## Action: Find and Replace

If you create a project from a factory, you can have {{ site.product_mini_name }} perform a find / replace on values in the imported source code after it is imported into the project tree. This essentially lets you parameterize your source code. Find and replace can be run as a **Run Command** during `onProjectsLoaded` event. You can use `sed`, `awk` or any other tools that are available in your workspace environment.

Define a command for your workspace in `factory.workspace.workspaceConfig.commands`:

```
{
  "commandLine": "sed -i 's/***/userId984hfy6/g' /projects/console-java-simple/README.md",
  "name": "replace",
  "attributes": {
    "goal": "Common",
    "previewUrl": ""
  },
  "type": "custom"
}
```

In this example, we have created a named command `replace` which replaces `***` with a string in project's README.md.

Then register this command to the execution list linked to `onProjectsLoaded` event. In this example, `replace` command is executed after project is imported into a workspace:

```
"ide": {
    "onProjectsLoaded": {
      "actions": [
        {
          "properties": {
            "name": "replace"
          },
          "id": "runCommand"
        }
      ]
    }
  }
```

Use [regular expressions](https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html) in sed, both in find/replace and file/file types patterns.



## Creator  
This object has meta information that you can embed within the Factory. These attributes do not affect the automation behavior or the behavior of the generated workspace.

```json  
factory.creator : {
  "name"      : STRING,                // Name of author of this configuration file
  "email"     : STRING,                // Email address of author
  "created"   : EPOCHTIME,             // Set by the system
  "userId"    : STRING                 // Set by the system
}
```
