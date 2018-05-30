---
title: "Creating Factories"
keywords: chedir, factories
tags: [chedir, factories]
sidebar: user_sidebar
permalink: creating-factories.html
folder: portable-workspaces
---

{% include links.html %}


## Create a Factory in the Dashboard

| Action | In the user dashboard: `Dashboard > Factories > Create Factory`.
| Sample Factory | [https://codenvy.io/f?id=s38eam174ji42vty](https://codenvy.com/f?id=s38eam174ji42vty)

Creating a Factory in the dashboard gives you the most freedom and control. The simplest way is to create a Factory based on an existing workspace, but you can also create Factories based on a template we provide or by pasting in a `factory.json` file and then generating a Factory URL using our CLI or API. Learn more the JSON structure and options in our [Factory JSON reference][factories_json_reference].

A Factory created from the dashboard will be persisted into Che database and kept when upgrading to a newer version.

## Create a Factory in the IDE

| Action | In the IDE: `Workspace > Create Factory`.
| Sample Factory | [https://codenvy.io/f?id=s38eam174ji42vty](https://codenvy.com/f?id=s38eam174ji42vty)

Creating a Factory from inside the IDE in a running workspace will generate a Factory to replicate that workspace including both runtime and project settings.

A Factory created from the dashboard will be persisted onto {{ site.product_mini_name }} and kept when upgrading to a newer version.

## Create a Factory based on a Repo

| Action | Specify the repo URL. In this case the configuration must be stored inside the repository.
| Sample Factories | [http://codenvy.io/f?url=https://github.com/eclipse/che](http://codenvy.io/f?url=https://github.com/eclipse/che)<br>[http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server](http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server)<br>[http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project](http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project)

URL Factories work with GitHub and GitLab repositories. By using URL Factories, the project referenced by the URL is automatically imported.

The Factory URL can include a branch or a subfolder. Here is an example of optional parameters:
- `?url=https://github.com/eclipse/che` che will be imported with master branch
- `?url=https://github.com/eclipse/che/tree/5.0.0` che is imported by using 5.0.0 branch
- `?url=https://github.com/eclipse/che/tree/5.0.0/dashboard` subfolder dashboard is imported by using 5.0.0 branch

### Customizing URL Factories
There are 2 ways of customizing the runtime and configuration.

**Customizing only the runtime**

**<span style="color:red;">Dockerfile works on Docker infra only!</span>** 

Providing a `.factory.dockerfile` inside the repository will signal to the {{ site.product_mini_name }} URL Factory to use this Dockerfile for the workspace agent runtime. By default imported projects are set to a `blank` project type, however project type can be set in the `.factory.json` or workspace definition that the Factory inherits from.

**Customizing the project and runtime**  
Providing a `.factory.json` file inside the repository will signal to Che URL Factory to configure the project and runtime according to this configuration file. When a `.factory.json` file is stored inside the repository, any `Dockerfile` content is ignored as the workspace runtime configuration is defined inside the JSON file.

## Factory policies
Policies are a way to send instructions to the automation engine about the number of workspaces to create and their meta data such as lifespan and resource allocation.

## Limitations  
**Referer**
: Checks the hostname of the acceptor and only allows the Factory to execute if there is a match.

**Since** & **Until**
: Defines the time window in which the Factory can be activated. For example, instructors who want to create an exercise that can only be accessed for two hours could set these properties.

## Multiplicity  
Defines how many workspaces should be created from the factory.

**Multiple Workspaces: perClick**
: Every click of the Factory URL will generate a different workspace, each with its own identifier, name and resources.

**Single Workspace: perUser**
: Exactly one workspace will be generated for each unique user that clicks on the Factory URL. If the workspace has previously been generated, we will reopen the existing workspace.

See [JSON reference][factories_json_reference] to learn how to configure Factory policies.

## IDE Customization
You can instruct the Factory to invoke a series of IDE actions based upon events in the lifecycle of the workspace.

## Lifecycle Events
The lifecycle of the workspace is defined with the following events:
- `onAppLoaded` : Triggered when the IDE is loaded.
- `onProjectsLoaded` : Triggered when the workspace and all projects have been activated.
- `onAppClosed` : Triggered when the IDE is closed.

Each event type has a set of actions that can be triggered. There is no ordering of actions executed when you provide a list; {{ site.product_mini_name }} will asynchronously invoke multiple actions if appropriate.

## Factory Actions

Below is the list of all possible actions which can be configured with your Factory.

**Run Command**  
: _Description:_ Specify the name of the command to invoke after the IDE is loaded.
: _Associated Event:_ `onProjectsLoaded`

**Open File**  
: _Description:_ Open project files in the editor. Optionally define line to be highlighted.   
: _Associated Event:_ `onProjectsLoaded`

**Open a Welcome Page**
: _Description:_ Customize content of a welcome panel displayed when the workspace is loaded.  
: _Associated Event:_ `onAppLoaded`

**Warm on Uncommitted Changes**
: _Description:_ Opens a warning popup when the user closes the browser tab with a project that has uncommitted changes.  
: _Associated Event:_ `onAppClosed`

See the [Factory JSON reference][factories_json_reference.html#ide-customization] to learn how to configure Factory actions.

## Find and Replace

Sometimes you may not want to expose certain sensitive information in source code (passwords, URLs, account names, API keys etc). Factories make it possible to replace variables or placeholders with real values. Find and replace can be run as a **Run Command** during `onProjectsLoaded` event. You can use `sed`, `awk` or any other tools that are available in your workspace environment.

Find in the [Factory JSON reference][factories_json_reference.html#action-find-and-replace] a sample showing how to configure a "Find and Replace" command.
Alternatively, you may also add IDE actions in Factory tab, in User Dashboard.

Use [regular expressions](https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html) in sed, both in find/replace and file/file types patterns.


## Pull Request Workflow

Factories can be configured with a dedicated pull request workflow. The PR workflow handles local & remote branching, forking, and issuing the pull request. Pull requests generated from within {{ site.product_mini_name }} have another Factory placed into the comments of the pull requests that a PR reviewer can use to quickly start the workspace.

When enabled, the pull request workflow adds a contribution panel to the IDE.
![pull-request-panel.png]({{base}}{{site.links["pull-request-panel.png"]}}){:style="width: 50%"}  

## Repository Badging  

If you have projects in GitHub or GitLab, you can help your contributors to get started by providing them ready-to-code developer workspaces. Create a factory and add the following badge on your repositories `readme.md`:

```markdown  
[![Developer Workspace](https://codenvy.io/factory/resources/codenvy-contribute.svg)](your-factory-url)
```



## Nest Steps

Read on to learn more about:
- Customizing factories with the [Factory JSON reference][factories_json_reference].
Or jump back to the [Factory getting started page][factories-getting-started] if you missed it.
