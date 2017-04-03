---
tags: [ "eclipse" , "che" ]
title: Factory - JSON Reference
excerpt: "Creating a Factory."
layout: docs
permalink: /:categories/factory-json-reference/
---
{% include base.html %}

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

The `factory.workspace` is identical to the `workspace:{}` object for Eclipse Che and contains the structure of the workspace. Learn more about [the workspace JSON object](https://www.eclipse.org/che/docs/server/create-workspaces/index.html).

You can export {{ site.product_mini_name }} workspaces and then reuse the workspace definition within a Factory. {{ site.product_mini_name }} workspaces are composed of 0..n projects, 0..n environments which contain machine stacks to run the code, 0..n commands to perform against the code, and a type.

The `factory.policies`, `factory.ide` and `factory.creator` objects are unique to Factories. They provide meta information to the automation engine that alter the presentation of the Factory URL or the behavior of the provisioning.



## Gotchas
A few rules to remember when creating Factories:
- The linux distro you use needs to support rsync's `--usermap` parameter, some older distros (like Debian Wheezy don't).
- Any users created in your Dockerfile must have no password set for the SSH keys.

## Mixins
A mixin adds additional behaviors to a project as a set of new project type attributes.  Mixins are reusable across any project type. You define the mixins to add to a project by specifying an array of strings, with each string containing the identifier for the mixin.  For example, `"mixins" : [ "tour", "pullrequest" ]`.

| Mixin ID   | Description   
| --- | ---
| `pullrequest`  | Enables pull request workflow where {{ site.product_mini_name }} handles local & remote branching, forking, and pull request issuance. Pull requests generated from within {{ site.product_mini_name }} have another Factory placed into the comments of pull requests that a PR reviewer can consume. Adds contribution panel to the IDE. If this mixin is set, then it uses attribute values for `project.attributes.local_branch` and `project.attributes.contribute_to_branch`. <br><br> The `pullrequest` mixin requires additional configuration from the `attributes` object of the project.  If present, {{ site.product_mini_name }} will use the project attributes as defined in the Factory. If not provided, {{ site.product_mini_name }} will set defaults for the attributes. <br><br> Learn more about other mixins, on [`project : {}` object for Eclipse Che](https://www.eclipse.org/che/docs/server/rest-api/index.html)

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
Policies are a way to send instructions to the automation engine about the number of workspaces to create and their meta data such as lifespan, resource allocation, and chargeback location.

```json  
factory.policies : {
  "referer"   : STRING,               // Works only for clients from referer
  "since"     : EPOCHTIME,            // Factory works only after this date
  "until"     : EPOCHTIME,            // Factory works only before this date
  "create"    : [perClick | perUser]  // Create one workpace per click, user or account
}
```
<br>

```json  
factory.policies.resources : {
  "ram" : INTEGER                     // RAM in MB for workspace default environment
}
```

### Limitations
You can use `since : EPOCHTIME`, `until : EPOCHTIME` and `referer` as a way to prevent the Factory from executing under certain conditions.  `since` and `until` represent a valid time window that will allow the Factory to activate. For example, instructors who want to create an exercise that can only be accessed for two hours could set these properties.  The `referer` will check the hostname of the acceptor and only allow the Factory to execute if there is a match.

### Multiplicity
How many workspaces should be created?  If `create : perClick` then every click of the Factory URL will generate a different workspace, each with its own identifier, name and resources.  If `create : perUser`, then exactly one workspace will be generated for each unique user that clicks on the Factory URL. If the workspace has previously been generated, we will reopen the existing workspace and place the user into it.

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
: Triggered when the IDE is loaded

`onProjectsLoaded`  
: Triggered when the workspace and all projects have been activated

`onAppClosed`  
: Triggered when the IDE is closed

This is an example that associates a variety of actions with all of the events.

```json  
"ide" : {  
  "onProjectsLoaded" : {                // Actions triggered when a project is opened
    "actions" : [{  
      "id" : "openFile",                // Opens a file in editor. Open addl files by repeating
      "properties" : {                  // Specifies which file to open (include project name)
        "file" : "/my-project/pom.xml"
      }
    }, {  
      "id" : "findReplace",             // Find and replace values in source code
      "properties" : {  
        "in"          : "(pom\\.xm.*)|(test\\..*)",  // Which files?
        "find"        : "GROUP_ID",                  // What to replace?
        "replace"     : "Codenvy",                   // Replace with?
        "replaceMode" : "text_multipass"
      }
    }, {  
      "id" : "runCommand",              // Launch command after IDE opens
      "properties" : {    
        "name" : "MCI"
      }
    }
  ]},

  "onAppLoaded" : {                     // Actions to be triggered after IDE is loaded
    "actions" : [{  
      "id" : "openWelcomePage",         // Show a custom welcome panel and message
      "properties" : {  
        "authenticatedContentUrl"    : "http://media.npr.org/images/picture-show-flickr-promo.jpg",
        "authenticatedIconUrl"       : "https://codenvy.com/wp-content/uploads/2014/01/icon-android.png",
        "authenticatedTitle"         : "Welcome, John",
        "authenticatedNotification"  : "We are glad you are back!",
        "nonAuthenticatedContentUrl" : "http://media.npr.org/images/picture-show-flickr-promo.jpg",
        "nonAuthenticatedIconUrl"    : "https://codenvy.com/wp-content/uploads/2014/01/icon-android.png",
        "nonAuthenticatedTitle"      : "Welcome, Anonymous"
      }
    }
  ]},

  "onAppClosed" : {                     // Actions to be triggered when IDE is closed
    "actions" : [{  
      "id" : "warnOnClose"              // Show warning when closing browser tab
    }]
  }
}
```
Each event type has a set of actions that can be triggered. There is no ordering of actions executed when you provide a list; {{ site.product_mini_name }} will asynchronously invoke multiple actions if appropriate. Some actions can be configured in how they perform and will have an associated `properties : {}` object.

### onProjectsLoaded Event

| Action   | Properties?   | Description   
| --- | --- | ---
| `runCommand`   | Yes   | Specify the name of the command to invoke after the IDE is loaded. Specify the commands in the `factory.workspace.commands : []` array.   
| `openFile`   | Yes   | Open project files as a tab in the editor.   
| `findReplace`   | Yes   | Find and replace text in source files with regex.   

### onAppLoaded Event

| Action   | Properties?   | Description   
| --- | --- | ---
| `openWelcomePage`   | Yes   | Customize the content of the welcome panel when the workspace is loaded.   

### onAppClosed Event

| Action   | Properties?   | Description   
| --- | --- | ---
| `warnOnClose`   | No   | Opens a warning popup when the user closes the browser tab wtih a project that has uncommitted changes. Requires `project.parameters.keepVcs` to be `true`.   

#### Action: Open File
This action will open a file as a tab in the editor. You can provide this action multiple times to have multiple files open. The file property is a relative reference to a file in the project’s source tree. The `file` parameter is the relative path within the workspace to the file that should be opened by the editor. Note that projects are located in the workspaces `/projects` folder.

```json  
{  
  "id" : "openFile",
    "properties" : {  
    "file" : "/my-project/pom.xml"
  }
}
```

#### Action: Find / Replace Values After Project Cloning  
If you create a project from a factory, you can have {{ site.product_mini_name }} perform a find / replace on values in the imported source code after it is imported into the project tree. This essentially lets you parameterize your source code.

Parameterizing source code allows you to create projects whose source code will be different for each click on the Factory. The most common use of this is inserting a developer-specific key into the source code. Each developer has their own key which is known to you. That key is inserted as the replacement variable and then inserted into the source code when that user invokes the Factory URL.

Parameterization works by replacing templated variables in the source code with values specified in the Factory object. The `findReplace` action is triggered by the `factory.ide.onProjectsLoaded : {}` event. It is an array of JSON objects, so you can perform multiple parameterizations on your source tree.

```json  
"onProjectOpened" : {                          
  "actions" : [{  
      "id" : "findReplace",            
      "properties" : {  
        "in"          : "(pom\\.xm.*)|(test\\..*)",  // Which files?
        "find"        : "GROUP_ID",                  // What to find?
        "replace"     : "Codenvy",                   // Replace with?
        "replaceMode" : "test_multipass"
      }
    }]
}
```
##### Regex Format  
The `in` parameter specifies which files in the source tree to perform the find / replace function on. The value is a path format provided as a regular expression. Visit regex reference page for more details.

##### Replacement Mode  
The `replaceMode` property indicates which replacement algorithm should be applied:
* `variable_singlepass`: Variables that start with ‘$’ and enclosed with curly brackets {} will be searched. For example, to replace variable `VAR_1_NAME` in the resulting code, put `${VAR_1_NAME}` variable in the source code. `${VAR_1_NAME}` will become `VAR_1_NAME`.
* `text_multipass`: Plain text will be searched. This is slower since all text must be searched.

It is possible to combine two replacement methods. Priority is given to singlepass. If no replacement method is specified, `variable_singlepass` mode will be used.

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

{% if site.product_mini_cli=="che" %}
Eclipse Che does not provide user management capabilities, the `factory.creator` is always be bound to a simulated `Che` user.
{% endif %}


## NEXT STEPS
You have just created your first developer workspace with Chedir. Read on to learn more about [project setup]({{base}}/docs/chedir/project-setup/index.html).
