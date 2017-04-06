---
tags: [ "eclipse" , "che" ]
title: Runtime Stacks
excerpt: "Stacks define the workspace runtime, commands, and configuration."
layout: docs
permalink: /:categories/runtime-stacks/
---
{% include base.html %}

A stack is a runtime configuration for a workspace. It contains a [runtime recipe]({{base}}{{site.links["ws-recipes"]}}), meta information like tags, description, environment name, and security policies. Since Che supports different kinds of runtimes, there are different stack recipe formats.

Stacks are displayed within the user dashboard and stack tags are used to filter the [project code samples]({{base}}{{site.links["ws-samples"]}}) that are available. It is possible to have a single stack with a variety of different project samples, each of which are filtered differently.

You can use Che's [built-in stacks]({{base}}{{site.links["ws-stacks"]}}#using-stacks-to-create-a-new-workspace) or [author your own custom stacks]({{base}}{{site.links["ws-stacks"]}}#custom-stack).

A stack is different from a [recipe]({{base}}{{site.links["ws-recipes"]}}). A stack is a JSON definition with meta information which includes a reference to a recipe. A recipe is either a [Dockerfile](https://docs.docker.com/engine/reference/builder/) or a [Docker compose file](https://docs.docker.com/compose/) used by Che to create a runtime that will be embedded within the workspace.  It is also possible to write a custom plug-in that replaces the default Docker machine implementation within Che with another one. For details on this, see [Building Extensions]({{base_che}}{{site.links["plugins-create-and-build-extensions"]}}) and / or start a dialog with the core Che engineers at `che-dev@eclipse.org`.

# Using Stacks To Create a New Workspace  
To create a new workspace in the user dashboard:

- Click `Dashboard` > `Create Workspace`
- Click `Workspaces` > `Add Workspace`
- Hit the “+” next to `Recent Workspaces`

![che-stacks1.jpg]({{base}}{{site.links["che-stacks1.jpg"]}})  

The stack selection form is available in the “Select Workspace” section, it allows you to choose stacks provided with Che or create and edit your own stack.

## Ready-To-Go Stacks
Che provides ready-to-go stacks for various technologies. These stacks provide a default set of tools and commands that are related to a particular technology.

## Stack Library
Che provides a wider range of stacks which you can browse from the “Stack library” tab. This list contains advanced stacks which can also be used as runtime configuration for your workspaces.

![che-stacks2.jpg]({{base}}{{site.links["che-stacks2.jpg"]}})

## Custom Stack
User can create their own stack from the "Custom stack" tab. Using Che's interface the user can provide a [runtime recipe]({{base}}{{site.links["ws-recipes"]}}) from an existing external recipe file or by writing a recipe directly.

Che provides a form that can be used to write a recipe directly or copied/pasted from an existing location. A recipe can be written directly as a Dockerfile or a Docker compose file and Che will detect which one it is automatically based on syntax. Refer to [runtime recipes]({{base}}{{site.links["ws-recipes"]}}) documentation for additional information.

# Stack Administration  
## Stack Loading
In 5.x, we introduced an underlying database for storing product configuration state, including the state of stacks and templates. In previous versions, we primarily allowed stack configuration through a `stacks.json` object file that was in the base of a Che assembly. The `stacks.json` object file is still there, and if you provide any stack definitions within it, they will be loaded (and override!) any stacks in the database whenever Che starts. We will be removing support for the JSON configuration approach in upcoming releases as it is error prone.

## Configuring Stacks
In the user dashboard, click the `Stacks` to view all the available stacks. New stacks can be created and existing stacks can be modified/searched.

*Java Stack Example - Annotated*

```json  
{
  // Tags describes components that make up the stack such as Tomcat, PHP, etc.
  // Tags are listed on stacks when creating a workspace.
  "tags": [
    "Java",
    "JDK",
    "Maven",
    "Tomcat",
    "Subversion",
    "Ubuntu",
    "Git"
  ],
  // Creator is the name of the person or organization that wrote the stack.
  "creator": "ide",
  // Workspace configuration defines environments, commands, and project info.
  "workspaceConfig": {
    "defaultEnv": "default",
    "commands": [
      {
        // Commands will be pre-loaded in the workspace. They use bash syntax.
        "commandLine": "mvn clean install -f ${current.project.path}",
        "name": "build",
        "type": "mvn",
        "attributes": {}
      }
    ],
    // Projects can be pre-loaded into the workspace.
    "projects": [],
    // Name of the workspace as it appears in the IDE.
    "name": "default",
    "environments": {
      "default": {
        "recipe": {
          "location": "codenvy/ubuntu_jdk8",
          "type": "dockerimage"
        },
        "machines": {
          "dev-machine": {
            "servers": {},
            // Agents are injected into the workspace to provide special funtions.
            "agents": [
              "org.eclipse.che.terminal",
              "org.eclipse.che.ws-agent",
              "org.eclipse.che.ssh"
            ],
            // Sets the RAM allocated to the machine.
            "attributes": {
              "memoryLimitBytes": "2147483648"
            }
          }
        }
      }
    },
    "links": []
  },
  // Name field is used in the "Components" column of the Stack table in Codenvy.
  "components": [
    {
      "version": "1.8.0_45",
      "name": "JDK"
    },
    {
      "version": "3.2.2",
      "name": "Maven"
    },
    {
      "version": "8.0.24",
      "name": "Tomcat"
    }
  ],
  // Description appears at the bottom of the Stack's "tile" in the dashboard.
  "description": "Default Java Stack with JDK 8, Maven and Tomcat.",
  "scope": "general",
  "source": {
    "origin": "codenvy/ubuntu_jdk8",
    "type": "image"
  },
  // Unique name and ID for the stack.
  "name": "Java",
  "id": "java-default"
}
```

Learn more about the stack data model on the [following page]({{base}}{{site.links["ws-data-model-stacks"]}})

## Create a Stack
A stack can be created from scratch using a skeleton template or duplicated from an existing stack.

To create a stack from scratch click the `Add Stacks` button at the top left of the page. This will load a skeleton template that can be edited. After editing the template configuration and changing the stack name, clicking the save button to add the new stack to the available stacks.

![che-add-stack.gif]({{ base }}{{site.links["che-add-stack.gif"]}})

## Duplicate a Stack
Duplicating an existing stack is often a good way to create your own. Click the duplicate icon on the right of the stack item you want. This will create a new stack name `<original name> - Copy` which can then be renamed and its configuration edited.

![Che-Stack-Duplicate.jpg]({{ base }}{{site.links["Che-Stack-Duplicate.jpg"]}})

## Edit a Stack
Stack name and configuration can be edited by clicking on the stack which will bring up the stack editing interface. The stack can be renamed at the top of the stack editing interface. The stack configuration can be changed using the provided forms. After editing is complete, the stack can be saved by clicking the save button.

![che-edit-stack.gif]({{ base }}{{site.links["che-edit-stack.gif"]}})

## Test a Stack
The built-in stacks editor allows to author your stack and test them in a temporary workspace. When testing the new stack, Che spins up a temporary and isolated workspace using the stack you just defined. You can use the temporary workspace to import your project, test commands and ensure all the components you need are properly configured. Once the testing session is completed the temporary workspace will be automatically deleted.

Test the stack by clicking the `Test` button - it will start the temporary workspace as an overlay over the dashboard.

![che-test-stack.gif]({{ base }}{{site.links["che-test-stack.gif"]}})

You can stop the testing session and the temporary workspace by clicking on the `Close` icon

## Delete a Stack
Stacks can be deleted by clicking the checkbox on the left then the delete button that appear on the top right of the page or by clicking the trash bin icon on the right side of the stack item.

![Che-Stack-Delete.jpg]({{ base }}{{site.links["Che-Stack-Delete.jpg"]}})

## Register a Custom Stack
Che has a stack API that you can call to manage your custom stacks. See the [Stacks]({{base_che}}{{site.links["server-stack"]}}) page in section _Use Che as a workspace server_ section.

# Adding Stacks to the Che Default Assembly  
If you are extending Eclipse Che, you can alter the default stacks provided with your custom assembly. In order to do that, you have to modify the `stacks.json` which is used to initialize Che's stacks.
This file is located here:
[https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json](https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json)

To create a stack, you need to define its configuration according to the [stack data model]({{base}}{{site.links["ws-data-model-stacks"]}}).

Also, if you believe your custom stack would be useful to others issue a pull request against the `stacks.json` at [https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json](https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json). If accepted this will add your stack to the default stack library in the product.
