---
tags: [ "eclipse" , "che" ]
title: Runtime Stacks
excerpt: "Stacks define the workspace runtime, commands, and configuration."
layout: docs
permalink: /:categories/runtime-stacks/
---
{% include base.html %}

A stack is a runtime configuration for a workspace. It contains a [runtime recipe]({{base}}{{site.links["devops-runtime-recipes"]}}), meta information like tags, description, environment name, and security policies. Since Che supports different kinds of runtimes, there are different stack recipe formats.

Stacks are displayed within the user dashboard and stack tags are used to filter the [project code samples]({{base}}{{site.links["devops-project-samples"]}}) that are available. It is possible to have a single stack with a variety of different project samples, each of which are filtered differently.

You can use Che's [built-in stacks]({{base}}{{site.links["devops-runtime-stacks"]}}#using-stacks-to-create-a-new-workspace) or [author your own custom stacks]({{base}}{{site.links["devops-runtime-stacks"]}}#custom-stack).

A stack is different from a [recipe]({{base}}{{site.links["devops-runtime-recipes"]}}). A stack is a JSON definition with meta information which includes a reference to a recipe. A recipe is either a [Dockerfile](https://docs.docker.com/engine/reference/builder/) or a [Docker compose file](https://docs.docker.com/compose/) used by Che to create a runtime that will be embedded within the workspace.  It is also possible to write a custom plug-in that replaces the default Docker machine implementation within Che with another one. For details on this, see [Building Extensions]({{base_che}}{{site.links["assemblies-plugin-lifecycle"]}}) and / or start a dialog with the core Che engineers at `che-dev@eclipse.org`.

# Using Stacks To Create a New Workspace  
To create a new workspace in the user dashboard:

- Click `Dashboard` > `Create Workspace`
- Click `Workspaces` > `Add Workspace`
- Hit the “+” next to `Recent Workspaces`

![che-stacks1.png]({{base}}{{site.links["che-stacks1.png"]}})  

The stack selection form is available in the “Select Stack” section, it allows you to choose stacks provided with Che or create and edit your own stack.

## Quick Start Stacks
Che provides quick start stacks for various technologies. These stacks provide a default set of tools and commands that are related to a particular technology.

# Stack Administration  
## Stack Loading

Stacks are loaded from a JSON file that is packaged into resources of a special component deployed with a workspace master. This JSON isn't exposed to users and stack management is performed in User Dashboard (that uses REST API).

Stacks are loaded from a JSON file only when the database is initialized, i.e. when a user first stats Che. This is the default policy that can be changed. To keep getting updates with new Che stacks, set `CHE_PREDEFINED_STACKS_RELOAD__ON__START=true` in `che.env`. When set to true, stacks.json will be used to update Che database, each time Che server starts. This means Che will get all stacks in stacks.json and upload them to a DB. This way, you may make sure that you keep existing custom stacks (user-created) and get stack updates from new Che releases. New and edited stacks (for example those with fixes in stack definition) will be merged in. Conflicts are possible though, since for example, if a new Che version provides a new stack with the name "My Cool Stack" and a stack with this name somehow exists in a database, such a stack won't be saved to a DB.

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

Learn more about the stack data model on the [following page]({{base}}{{site.links["devops-runtime-stacks-data-model"]}})

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
Che has a stack API that you can call to manage your custom stacks. See the [Stacks]({{base_che}}{{site.links["devops-runtime-stacks"]}}) page in section _Use Che as a workspace server_ section.

# Adding Stacks to the Che Default Assembly  

If you believe your custom stack would be useful to others issue a pull request against the `stacks.json` at [https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json](https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json). If accepted this will add your stack to the default stack library in the product.

To create a stack, you need to define its configuration according to the [stack data model]({{base}}{{site.links["devops-runtime-stacks-data-model"]}}).

# Adding Stacks to the Che Custom Assembly

It is possible to provide custom stacks and package them into Che assembly instead of using the default Che stacks.
A JAR with stacks.json should be [packaged to Workspace Master WAR](https://github.com/eclipse/che-archetypes/blob/master/stacks-archetype/src/main/resources/archetype-resources/assembly-che/assembly-wsmaster-war/pom.xml#L29-L33), as well as default ["che-core-ide-stacks" JAR should be excluded](https://github.com/eclipse/che-archetypes/blob/master/stacks-archetype/src/main/resources/archetype-resources/assembly-che/assembly-wsmaster-war/pom.xml#L62-L64) from it. You can do it manually, but [Che archetype]({{base}}{{site.links["assemblies-archetype"]}}) will do it for you.

Che archetype `stacks-archetype` shows an example of replacing default stacks with a custom one:

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
  -v /c/Users/User/.m2/repository:/m2
    eclipse/che archetype generate --archid=stacks-archetype --che
```
