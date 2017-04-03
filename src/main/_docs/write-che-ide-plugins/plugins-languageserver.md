---
tags: [ "eclipse" , "che" ]
title: Language Server Protocol
excerpt: ""
layout: docs
permalink: /:categories/languageserver/
---

{% include base.html %}

The Language Server Protocol is used between a tool (the client) and a language intelligence provider (the server) to integrate features like auto complete, goto definition, find references, etc....

You can learn more about the language server specification on the [LSP GitHub page](https://github.com/Microsoft/language-server-protocol).

Currently Eclipse Che implements the [2.x protocol version](https://github.com/Microsoft/language-server-protocol/blob/master/versions/protocol-2-x.md).

## Creating A Language Server

### 1. General Concept

Language server integration is divided into 2 steps: an install followed by a separately triggered start. Language servers aren't started when the agent starts. Instead they are started in a second step which can be triggered at any time. This is done to reduce resource consumption and reduce workspace startup time.

1. The language server agent is launched when the workspace starts - its job is to install all dependencies and prepare the `bash` launcher file that will be used to start the language server.
2. The [launcher](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java) is triggered andstarts the language server. We suggest triggering the launcher when the user begins interacting with file types related to the language server. Once launched, the language server is registered with specific file types (covered in more detail below).

### 2. Adding a Language Server Agent

Follow the documentation on how to [add new agent]({{base}}{{site.links["ws-agents"]}}#creating-new-agents).

Examples of existed language server agents you can learn from:

* [JSON](https://github.com/eclipse/che/tree/master/agents/ls-json)
* [PHP](https://github.com/eclipse/che/tree/master/agents/ls-php)
* [Python](https://github.com/eclipse/che/tree/master/agents/ls-python)
* [C#](https://github.com/eclipse/che/tree/master/agents/ls-csharp)
* [TypeScript](https://github.com/eclipse/che/tree/master/agents/ls-typescript)

### 3. Adding a Language Server Launcher

Implement the [LanguageServerLauncher interface](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java).

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

You will need a [LanguageDescription](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver-shared/src/main/java/org/eclipse/che/api/languageserver/shared/model/LanguageDescription.java)
to describe the file types that your language server will be registered with.

Follow our language server launchers and descriptions examples:

* [Python](https://github.com/eclipse/che/blob/master/plugins/plugin-python/che-plugin-python-lang-server/src/main/java/org/eclipse/che/plugin/python/languageserver/PythonLanguageSeverLauncher.java)
* [C#](https://github.com/eclipse/che/blob/master/plugins/plugin-csharp/che-plugin-csharp-lang-server/src/main/java/org/eclipse/che/plugin/csharp/languageserver/CSharpLanguageServerLauncher.java)
* [JSON](https://github.com/eclipse/che/blob/master/plugins/plugin-json/che-plugin-json-server/src/main/java/org/eclipse/che/plugin/json/languageserver/JsonLanguageServerLauncher.java)

### 3. Bind the Language Server Launcher

```java
@DynaModule
public class MyLanguageServerModule extends AbstractModule {
    @Override
    protected void configure() {
        Multibinder.newSetBinder(binder(), LanguageServerLauncher.class).addBinding().to(MyLanguageServerLauncher.class);
    }
}
```

Once complete, compile and run Che. If everything has worked you will see your agent listed in the list of `Agents`:

![Che-machine-information-edit.jpg]({{base}}{{site.links["Che-machine-information-edit.jpg"]}})

The agent can be added by default in a Stack, our [Stack documentation]({{base}}{{site.links["ws-stacks"]}}) explains how to create and edit stacks.

### 4. Implement Code Action Commands
Through the LSP command "textDocument/codeAction", a language server can contribute items to the quick-assist menu in an editor. The language server returns a list of LSP `Command` objects. These command objects are mapped to Che actions by looking up an action by id in the `ActionManager` using the `command` field of the command object. 
The extra parameters from the command object are passed to the action by using an extended `ActionEvent`:

```java

public class QuickassistActionEvent extends ActionEvent {

	private List<Object> arguments;

	public QuickassistActionEvent(Presentation presentation, ActionManager actionManager, PerspectiveManager perspectiveManager, List<Object> arguments) {
		super(presentation, actionManager, perspectiveManager);
		this.arguments= arguments;
	}

	public List<Object> getArguments() {
		return arguments;
	}
}
```

Language server launcher IDE plugins may contribute their own actions to be called. The language server plugin itself contributes an action with the id "lsp.applyTextEdit", which will apply a list of LSP `TextEdit` objects in the currently active editor.

