---
tags: [ "eclipse" , "che" ]
title: Language Server
excerpt: ""
layout: docs
permalink: /:categories/languageserver/
---
{% include base.html %}
## Language Server Protocol
The Language Server protocol is used between a tool (the client) and a language smartness provider (the server) to integrate features like auto complete, goto definition, find all references and alike into the tool.

You can learn more on the language server specification [here](https://github.com/Microsoft/language-server-protocol).

Currently Eclipse Che implements [2.x protocol version](https://github.com/Microsoft/language-server-protocol/blob/master/versions/protocol-2-x.md)

## How to create a custom assembly to try the language server

### 1. General concept

Language server integration is divided into 2 steps. 

At first step we launch agent when workspace starts to install all dependencies that are needed for proper functionality of the Language Server, download or install
 language server and prepare `bash` file (launcher) to start language server.
We don't start language server when agent starts. It is done on purpose for better resources consuming, reduce workspace start time and due to requiring path
 to the project to start language server.

At the second step we use [launcher](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java)
 to start language server. It is occurred when user begins interacting with files of the specific types.
 Then Che initializes and runs language server. How to register language server with file types is described below.

### 2. Adding language server agent

Follow the doc how to [add new agent]({{base}}{{site.links["ws-agents"]}}#creating-new-agents).

Examples of existed language server agents:
* [Json](https://github.com/eclipse/che/tree/master/agents/ls-json)
* [PHP](https://github.com/eclipse/che/tree/master/agents/ls-php)
* [Python](https://github.com/eclipse/che/tree/master/agents/ls-python)
* [C#](https://github.com/eclipse/che/tree/master/agents/ls-csharp)
* [TypeScript](https://github.com/eclipse/che/tree/master/agents/ls-typescript)

### 3. Adding language server launcher

Implement [LanguageServerLauncher interface](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java).

```java
public interface LanguageServerLauncher {

    /**
     * Initializes and starts language server.
     * 
     * @param projectPath
     *      absolute path to the project
     */
    LanguageServer launch(String projectPath) throws LanguageServerException;

    /**
     * Gets supported languages that language server is registered with.
     */
    LanguageDescription getLanguageDescription();

    /**
     * Indicates if language server is installed and is ready to be started. 
     * Returns {@code true} if everything is ok and {@code false} otherwise.
     * {@code false} might be return when language server agent failed and couldn't create launcher file.
     */
    boolean isAbleToLaunch();
}
```

[LanguageDescription](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver-shared/src/main/java/org/eclipse/che/api/languageserver/shared/model/LanguageDescription.java)
 describes file types that language server is registered with.

Follow our language server launchers and descriptions examples:
* [Python](https://github.com/eclipse/che/blob/master/plugins/plugin-python/che-plugin-python-lang-server/src/main/java/org/eclipse/che/plugin/python/languageserver/PythonLanguageSeverLauncher.java)
* [C#](https://github.com/eclipse/che/blob/master/plugins/plugin-csharp/che-plugin-csharp-lang-server/src/main/java/org/eclipse/che/plugin/csharp/languageserver/CSharpLanguageServerLauncher.java)
* [JSON](https://github.com/eclipse/che/blob/master/plugins/plugin-json/che-plugin-json-server/src/main/java/org/eclipse/che/plugin/json/languageserver/JsonLanguageServerLauncher.java)

### 3. Bind language server launcher

```java
@DynaModule
public class MyLanguageServerModule extends AbstractModule {
    @Override
    protected void configure() {
        Multibinder.newSetBinder(binder(), LanguageServerLauncher.class).addBinding().to(MyLanguageServerLauncher.class);
    }
}
```

Compile and run Che. If everything done well in the list of `Agents` you will see your custom agent.

![Che-machine-information-edit.jpg]({{base}}{{site.links["Che-machine-information-edit.jpg"]}})

The agent can be added by default in a stack. Follow the [guide]({{base}}{{site.links["ws-stacks"]}}) how to create and edit stacks.

