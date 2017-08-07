---
tags: [ "eclipse" , "che" ]
title: SDK Language Server Protocol
excerpt: ""
layout: docs
permalink: /:categories/sdk-language-server-protocol/
---

{% include base.html %}

The Language Server Protocol is used between a tool (the client) and a language intelligence provider (the server) to integrate features like auto complete, goto definition, find references, etc....

You can learn more about the language server specification on the [LSP GitHub page](https://github.com/Microsoft/language-server-protocol).

Currently Eclipse Che implements the [2.x protocol version](https://github.com/Microsoft/language-server-protocol/blob/master/versions/protocol-2-x.md).

## Creating A Language Server

### 1. General Concept

Language server integration is divided into 2 steps: an install followed by a separately triggered start. Language servers aren't started when the agent starts. Instead they are started in a second step which can be triggered at any time. This is done to reduce resource consumption and reduce workspace startup time.

1. The language server agent is launched when the workspace starts - its job is to install all dependencies and prepare the `bash` launcher file that will be used to start the language server.
2. The [launcher](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java) is triggered and starts the language server. We suggest triggering the launcher when the user begins interacting with file types related to the language server. Once launched, the language server is registered with specific file types (covered in more detail below).

### 2. Adding a Language Server Agent

Follow the documentation on how to [add new agent]({{base}}{{site.links["devops-ws-agents"]}}#creating-new-agents).

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

    //**
     * Initializes and starts a language server.
     *
     * @param projectPath
     *      absolute path to the project
     * @param client
     *      an interface implementing handlers for server->client communication
     */
    LanguageServer launch(String projectPath, LanguageClient client) throws LanguageServerException;

    /**
     * Gets the language server description
     */
    LanguageServerDescription getDescription();

    /**
     * Indicates if language server is installed and is ready to be started.  
     */
    boolean isAbleToLaunch();
}
```

[LanguageServerDescription](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/registry/LanguageServerDescription.java) and [LanguageDescription](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver-shared/src/main/java/org/eclipse/che/api/languageserver/shared/model/LanguageDescription.java) are used to describe the types of file your language server will make contributions to.

Follow our language server launchers and descriptions examples:

* [Python](https://github.com/eclipse/che/blob/master/plugins/plugin-python/che-plugin-python-lang-server/src/main/java/org/eclipse/che/plugin/python/languageserver/PythonLanguageSeverLauncher.java)
* [C#](https://github.com/eclipse/che/blob/master/plugins/plugin-csharp/che-plugin-csharp-lang-server/src/main/java/org/eclipse/che/plugin/csharp/languageserver/CSharpLanguageServerLauncher.java)
* [JSON](https://github.com/eclipse/che/blob/master/plugins/plugin-json/che-plugin-json-server/src/main/java/org/eclipse/che/plugin/json/languageserver/JsonLanguageServerLauncher.java)

### 4. Bind the Language Server Launcher and Language Description
A language description tells the system that a LSP-based editor should be used for a particular file and associates a language identifier with
those files. It can be configured in your plugin's module definition:

```java
@DynaModule
public class MyLanguageServerModule extends AbstractModule {
    @Override
    protected void configure() {
        Multibinder.newSetBinder(binder(), LanguageServerLauncher.class).addBinding().to(MyLanguageServerLauncher.class);
        LanguageDescription description = new LanguageDescription();
        description.setFileExtensions(asList("foo", "bar"));
        description.setFileNames(asList("foobar.txt", "foobar.xml"));

        description.setLanguageId("myLanguage");
        description.setMimeType("text/foobar");
        Multibinder.newSetBinder(binder(), LanguageDescription.class).addBinding().toInstance(description);
    }
}
```
Any time results from language servers are required, the system finds all contributing language servers by matching the their `LanguageServerDescription` against the file URI and the associated language identifier. A language server can register multiple `DocumentFilter` instances. The results of the operations are merged. When only a single language server can be used (like when formatting, for example), servers will be prioritized, with those matching ".*" at the end of the list. If multiple servers have the same priority, the first registered will be chosen. For example, here is the language server decription for the JSON server:

```java
 description = new LanguageServerDescription(
    "org.eclipse.che.plugin.json.languageserver",
    null,
    Arrays.asList(new DocumentFilter(JsonModule.LANGUAGE_ID, ".*\\.(json|bowerrc|jshintrc|jscsrc|eslintrc|babelrc)",
    null)));
```

Once complete, compile and run Che. If everything has worked you will see your agent listed in the list of `Agents`:

![Che-machine-information-edit.jpg]({{base}}{{site.links["Che-machine-information-edit.jpg"]}})

The agent can be added by default in a Stack, our [Stack documentation]({{base}}{{site.links["devops-runtime-stacks"]}}) explains how to create and edit stacks.

### 5. Implement Code Action Commands
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
