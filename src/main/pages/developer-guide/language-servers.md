---
title: "Language Support"
keywords: framework, language servers, code assistant, language support, code completion, error marking
tags: [extensions, assembly, dev-docs]
sidebar: user_sidebar
permalink: language-servers.html
folder: developer-guide
---

{% include links.html %}

## Overview

The Language Server Protocol is used between a tool (the client) and a language intelligence provider (the server) to integrate features like auto complete, goto definition, find references, etc.

You can learn more about the language server specification on the [LSP GitHub page](https://github.com/Microsoft/language-server-protocol).

Currently Eclipse Che implements the [3.x protocol version](https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md).

Note that, Eclipse Che also implements the snippet syntax used in VSCode. It is not versioned in the LSP specification, but the supported syntax is described [here](https://github.com/Microsoft/vscode/blob/0ebd01213a65231f0af8187acaf264243629e4dc/src/vs/editor/contrib/snippet/browser/snippet.md).

## Adding Support for New Languages

There are two approaches to add a new language server:

* via installer and launcher: this way a language server runs in the machine where the respective installer has been enabled
* adding [language server as a sidecar](#ls-sidecars) in workspace configuration - multi-machine recipe + server with required attributes

## General Concept

Language server integration is divided into 2 steps: an install followed by a separately triggered start. Language servers aren't started when the agent starts. Instead they are started in a second step which can be triggered at any time. This is done to reduce resource consumption and reduce workspace startup time.

1. The language server agent is launched when the workspace starts - its job is to install all dependencies and prepare the `bash` launcher file that will be used to start the language server.
2. The [launcher](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/launcher/LanguageServerLauncher.java) is triggered and starts the language server. We suggest triggering the launcher when the user begins interacting with file types related to the language server. Once launched, the language server is registered with specific file types (covered in more detail below).

## Adding a Language Server Installer

Follow the documentation on how to [add new installer][custom-installers].

Examples of existed language server agents you can learn from:

* [JSON](https://github.com/eclipse/che/tree/master/agents/ls-json)
* [PHP](https://github.com/eclipse/che/tree/master/agents/ls-php)
* [Python](https://github.com/eclipse/che/tree/master/agents/ls-python)
* [C#](https://github.com/eclipse/che/tree/master/agents/ls-csharp)
* [TypeScript](https://github.com/eclipse/che/tree/master/agents/ls-typescript)

## Adding a Language Server Launcher

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

## Bind Language Server Launcher and Language Description

A language description tells the system that an LSP-based editor should be used for a particular file and associates a language identifier with
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

Once complete, compile and run Che. If everything has worked you will see your installer listed in the list of [installers][installers]:

The agent can be added by default in a Stack, our [Stack documentation][stacks] explains how to create and edit stacks.

## Implement Code Action Commands

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

Language server launcher IDE plugins may contribute their own actions to be called. The language server plugin itself contributes two actions with the ids "lsp.applyTextEdit" and "lsp.applyWorkspaceEdit". The first will apply a list of LSP `TextEdit` objects in the currently active editor. The second one applies a an LSP `WorkspaceEdit` to files in the workspace, either in an editor if the file is open, or on disk if they are not.

## LS-Sidecars

While the above approach works well for custom assemblies, i.e. you actually need to rebuild Che with a custom plugin that registers a new installer and a language server launcher, there is a mechanism to launch Language Servers in parallel containers/sidecars. This is what you need to do to add a new language server to your workspace as a sidecar.

* Build a Docker image in which language server is started in `ENTRYPOINT` or `CMD`. Note that some language servers support `tcp` arguments in their start syntax. Make sure that the language server acts like a server, rather than attempts to bind to a socket. The best way to check it is to run the image: `docker run -ti ${image}`. If the container starts, everything is fine, and if it exits immediately, you need to fix it.

We recommend running language servers in `stdio` mode and use sockat as a proxy. Here's an example of a Dockerfile that builds an image with TyperScript language server:

```
# inherit an image with node.js and npm - runtime requirements for TypeScript LS
FROM eclipse/node

# install socat
RUN sudo apt-get install socat -y && \
    sudo npm install -g typescript@2.5.3 typescript-language-server@0.1.4

# run socat that listens on port 4417 with exec command that starts LS
CMD socat TCP4-LISTEN:4417,reuseaddr,fork EXEC:"typescript-language-server --stdio"
```

* Create a stack with a [custom recipe][creating-starting-workspaces]: Create Workspace > Add Stack:

```yaml
services:
 typescript-ls-machine:
  image: ls/image
  mem_limit: 1073741824
 dev-machine:
  image: eclipse/ubuntu_jdk8
  mem_limit: 2147483648
  depends_on:
   - typescript-ls-machine
```

* In User Dashboard, go to **Workspaces > Your Workspace > Config**, and add a server for typescript-ls-machine in `servers:[]`

```json
"servers": {
  "ls": {
    "attributes": {
      "internal": "true",
      "type": "ls",
      "config": "{\"id\":\"tsls\", \"languageIds\":[typescript]}"
    },
    "protocol": "tcp",
    "port": "4417"
  }
}
```
* **ls** - server name - can be any string
* **attributes.internal** - `true`. Mandatory! Used to get an internal link to server
* **attributes.type** - `ls`. Mandatory. Used by the IDE client to identify a server as a language server
* **attributes.config.id** - LS ID - any string. Used as LS identifier
* **attributes.config.languageIds** - List of registered Language IDs. You can either [register own](#bind-language-server-launcher-and-language-description) (in this case you need own custom Che assembly) or use any ID from the [default list](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-languageserver/src/main/java/org/eclipse/che/api/languageserver/registry/DefaultLanguages.java) that covers most popular languages. Each Language ID has associated file extensions.

* In User Dashboard, go to Workspaces > Your Workspace > Volumes, add a volume for **each machine**. The two volumes have to share the same name (for example, `projects`) and path `/projects` so that they actually share one volume. This way a language server container has access to workspace project types.

{% include image.html file="extensibility/lang_servers/volumes_ls.png" %}

* Start a workspace. Open a file with one of the extensions bound to a language ID. Che client will attempt to connect to language server over tcp socket. This data is retrieved from workspace runtime. Language server process should be available at the port declared in the server. You can either use Socat or launch a language server in tcp mode if it supports it. It is your Docker image's responsibility to launch the language server. Adding `ENTRYPOINT` or `CMD` instruction should work well.
