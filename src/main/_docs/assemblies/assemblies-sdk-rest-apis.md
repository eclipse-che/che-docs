---
tags: [ "eclipse" , "che" ]
title: SDK REST APIs
excerpt: ""
layout: docs
permalink: /:categories/sdk-rest-apis/
---
{% include base.html %}
The components in an assembly communicate with one another using REST APIs. For example, REST is the format for how IDE plugins in the browser will talk to those running in a workspace agent or within the master server.

Che provides helper utilities to make REST calls simpler. Che's REST library is built on top of Google's HTTP Java client libraries.

# Java Utilities
In your extension code, you can create an `AsyncRequestFactory` object, which has helper methods for creating requests that will have responses.

```java  
private void getProjectType(@NotNull String workspaceId,
                            @NotNull String id,
                            @NotNull AsyncCallback<ProjectTypeDto> callback) {

    final String url = appContext.getDevMachine().getWsAgentBaseUrl() + "/project-type/";
    asyncRequestFactory.createGetRequest(url)
                       .header(ACCEPT, APPLICATION_JSON)
                       .loader(loaderFactory.newLoader("Getting info about project type..."))
                       .send(newCallback(callback,
                                         dtoUnmarshallerFactory.newUnmarshaller(ProjectTypeDto.class)));

}
```
This example comes from the class used by the IDE to ask the server to provide a response on what the current project type is within the currently active workspace. The `asyncRequestFactory` object was instantiated by the system as an input parameter. Calling the `createGetRequest()` method with the GET REST URL as an input will generate a request and a response. The `.loader()` method is an optional display component that will appear on the screen while the contents of the response are loading. The `send()` method takes a callback object which will be invoked by the system when a response is delivered.

In the [debugger implementation class](https://github.com/eclipse/che/blob/e3407ae74674c5f84af89341826ec5e98106f90e/plugins/plugin-java/che-plugin-java-ext-debugger-java-client/src/main/java/org/eclipse/che/ide/ext/java/jdi/client/debug/DebuggerServiceClientImpl.java), you can see a range of REST calls for different individual functions such as step into, step over, and  so forth.

In the [Java content assist class](https://github.com/eclipse/che/blob/e3407ae74674c5f84af89341826ec5e98106f90e/plugins/plugin-java/che-plugin-java-ext-lang-client/src/main/java/org/eclipse/che/ide/ext/java/client/editor/JavaCodeAssistClient.java), you can see the sequence of REST calls that are made for generating requests for information from the server about intellisense features that can only be processed on the server side.

#### Callbacks
In Che, you will frequently see `AsyncRequestCallback<T>` objects passed into an `AsyncRequestFactory` object. Callbacks will be invoked by the system when a response is returned. This class inherits from `com.google.gwt.http.client.RequestCallback` and we add in a few additional objects:
1. `Unmarshallable<T>` which is logic to convert the response payload from data into a Java object.
2. `AsyncRequestLoader` which is a visual loader to display while downloading data.
3. `AsyncRequest` which is the original request.

Che provides different types of `Unmarshallable` objects including [StringUnmarshaller](https://github.com/eclipse/che/blob/0d0bbf900114e9c9964d386b02f0904a913ae4e0/core/commons/che-core-commons-gwt/src/main/java/org/eclipse/che/ide/rest/StringUnmarshaller.java), [StringMapUnmarshaller](https://github.com/eclipse/che/blob/0d0bbf900114e9c9964d386b02f0904a913ae4e0/core/commons/che-core-commons-gwt/src/main/java/org/eclipse/che/ide/rest/StringMapUnmarshaller.java), [StringMapListUnmarshaller](https://github.com/eclipse/che/blob/0d0bbf900114e9c9964d386b02f0904a913ae4e0/core/commons/che-core-commons-gwt/src/main/java/org/eclipse/che/ide/rest/StringMapListUnmarshaller.java), [DtoUnmarshaller](https://github.com/eclipse/che/blob/0d0bbf900114e9c9964d386b02f0904a913ae4e0/core/commons/che-core-commons-gwt/src/main/java/org/eclipse/che/ide/rest/DtoUnmarshaller.java), and [LocationUnmarshaller](https://github.com/eclipse/che/blob/0d0bbf900114e9c9964d386b02f0904a913ae4e0/core/commons/che-core-commons-gwt/src/main/java/org/eclipse/che/ide/rest/LocationUnmarshaller.java).  These different marshallers represent the most common types of JSON to Java payload conversions.

For example, this logic comes from the git plugin and is the method that is called when a user asks to delete the local git repository contained within the project.

*che/plugins/plugin-git/che-plugin-git-ext-git/src/main/java/org/eclipse/che/ide/ext/git/client/delete/DeleteRepositoryPresenter.java*

```java  
public void deleteRepository() {
    final CurrentProject project = appContext.getCurrentProject();
    final GitOutputConsole console = gitOutputConsoleFactory.create(DELETE_REPO_COMMAND_NAME);

     service.deleteRepository(workspaceId, project.getRootProject(),
                              new AsyncRequestCallback<Void>() {
        @Override
        protected void onSuccess(Void result) {
            console.print(constant.deleteGitRepositorySuccess());
            consolesPanelPresenter.addCommandOutput(appContext.getDevMachineId(), console);
            notificationManager.notify(constant.deleteGitRepositorySuccess(), project.getRootProject());
            getRootProject(project.getRootProject());
        }

        @Override
        protected void onFailure(Throwable exception) {
            // The logic for what to do if the response generated a failure message
        }
    });
}
```

In this example, the `service.deleteRepository(...)` is a method that will generate the `AsyncRequestFactory` object for calling the server. This object requires a `AsyncRequestCallback<T>`. This method creates a new instance inline with a callback that expects the response to send data of `Void` type, which basically means that there is no response payload. In this case, either the server tells us there is success or there is failure. The `AsyncRequestCallback` instance needs to implement two methods `onSuccess(<T>)` and `onFailure(Throwable)`, which will be called by the `AsyncRequestFactory` when the response arrives on the wire. It is within these methods that the logic is placed that tells the IDE what to do in each event.

# Browsing REST APIs
There are numerous existing APIs within the master and agent assemblies that you can reuse as part of your extension development. These APIs are browsable if you already have Che or Codenvy running using Swagger.

There are APIs that are hosted within the {{ site.product_mini_name }} server, which we call workspace master APIs for managing workspaces. And there are APIs that are hosted within each workspace, launched and hosted by a workspace agent that is injected into each workspace machine when it boots.

In addition to browsing the included REST APIs, we provide a few different examples below on how some of the various APIs work.

### Workspace Master APIs  

![Swagger.PNG]({{ base }}/docs/assets/imgs/Swagger.PNG)

```http  
http://localhost:8080/swagger/
```

### Workspace Agent APIs  
Each workspace has its own set of APIs. The workspace agent advertises its swagger configuration on a different port.  

```shell  

# Example
http://172.19.20.16:8080/swagger/?url=http://172.19.20.16:32771/api/docs/swagger.json

where 32771 is an exposed port mapped to port 4401
```

* You can get ws-agent API endpoint from workspace runtime:

`GET localhost:8080/api/workspace/ws-id` `> runtime > devMachine > runtime > servers > links > 4401/tcp > address`.

* You can get workspace agent port by running `docker inspect` against a workspace container. Get workspace container ID (image name is smth like `eclipse-che/workspacef4g2rqfw2222d81u_machine5c0ezeh7jixthtft_che_dev-machine`) and then run:

`docker inspect $containerID --format='{{(index (index .NetworkSettings.Ports "4401/tcp") 0).HostPort}}'`

* API endpoint can be retrieved from your Java code as well:

`appContext.getDevMachine().getWsAgentBaseUrl()`

# Using REST APIs

Below are examples on how to call some ws-master and ws-agent APIs.

# Project API
In {{ site.product_mini_name }} a **Project** is an instance of a **Project Type** with concrete values for all attributes and a set of associated Source Code that resides within the Project’s file system.


## Import a Project Into a Running Workspace

This call physically imports a project into a workspace. A project must have project type defined and a list of mandatory attributes (depends on the project type).

Get a list of all available registered project types:

`GET http://localhost:32768/api/project-type`

```shell
curl -X POST -H 'Content-Type: application/json' -d '{ [
  "mixins":[  
     "git"
  ],
  "description":"A hello world Java application.\ "   name":"console-java-simple\ "   type":"maven\ "   path":"/console-java-simple\ "   attributes":{  
     "maven.artifactId":[  
        "console-java-simple"
     ],
     "maven.test.source.folder":[  
        "src/test/java"
     ],
     "maven.version":[  
        "1.0-SNAPSHOT"
     ],
     "maven.source.folder":[  
        "src/main/java"
     ],
     "maven.groupId":[  
        "org.eclipse.che.examples"
     ],
     "maven.packaging":[  
        "jar"
     ]
  }
]
}' http://localhost:32768/api/project/workspacesq6co30qcxi1kqsj/batch
```

#### Remove a Project

```shell  
curl -X DELETE http://localhost:8080/api/ext/project/workspacex4zl7nvex1yldosj/my-first-sample
```

# Project Type API

A **Project Type** is a behavior that apples a named group of attribute definitions, pre-defined attributes, and an associated set of machine images.

For example, within {{ site.product_mini_name }}, maven is a Project Type. Each Project Type can have a different set of attributes associated with it as defined by the author of the Project Type. Project Types can have both mandatory and optional attributes. Some attributes are pre-defined and cannot be changed. Some attributes can be derived by the extension at runtime and others must be defined by the Developer User when constructing a new Project.

Each Project Type has an associated set of machine images that are instantiated at runtime to execute Builders and Runners.

A single Project Type can have many machines associated with it that can be interchangeably used by developers. For example, a maven project can have multiple machines with different JVM, application server types, and versions, with the Project successfully executing within each machine.

Get a list of all available registered project types:

`GET http://localhost:32768/api/project-type`

Get a particular project type:

`GET http://localhost:32768/api/project-type/maven`

#### Estimate a Project Against a Project Type

```shell  
curl http://localhost:32768/api/project/estimate/c-simple-console?type=node-js
```

# Editing API
#### Create a New File

```shell
curl -X POST -d 'var i = 1;' http://localhost:32768/api/project/file/c-simple-console?name=newfile.js
```

#### Editing an Existing File

```shell
curl -X PUT -d $'var i = 1;\nvar test = "hello Eclipse Che";' http://localhost:32768/api/project/file/c-simple-console?name=newfile.js
```

#### Deleting an Existing File

```shell
curl -X DELETE http://localhost:32768/api/project/c-simple-console/newfile.js
```

# Workspace API

##### Save Project Into Workspace Configuration  

This API calls adds a project to workspace configuration and **does not** physically import a project into a workspace.

```shell  
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
      "links": [],
      "name": "web-java-spring",
      "attributes": {},
      "type": "maven",
      "source": {
        "location": "https://github.com/che-samples/web-java-spring.git",
        "type": "git",
        "parameters": {}
      },
      "path": "/web-java-spring",
      "description": "A basic example using Spring servlets. The app returns values entered into a submit form.",
      "problems": [],
      "mixins": []
 }' 'http://localhost:8080/api/workspace/workspace6y86s5qlnzbczow9/project'
 ```

#### Create a Command In A Workspace

```shell  
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
  "attributes": {
    "goal": "Run",
    "previewUrl": "http://${server.port.8080}"
  },
  "type": "custom",
  "commandLine": "echo \u0027Hello World\u0027",
  "name": "hello world",
  "goal": "run"
}' 'http://localhost:8080/api/workspace/workspace6y86s5qlnzbczow9/command'
```

Sample cURL code that creates a workspace named `workspace-debian` and displays resulting data in console:

#### Create a Workspace

```shell
curl -X POST -H 'Content-Type: application/json' -d '{"name":"myworkspace","projects":[],"commands":[{"name":"build","type":"mvn","attributes":{"goal":"Build","previewUrl":""},"commandLine":"mvn clean install"],"environments":{"myworkspace":{"recipe":{"location":"eclipse/ubuntu_jdk8","type":"dockerimage"},"machines":{"dev-machine":{"attributes":{"memoryLimitBytes":"2147483648"},"agents":["org.eclipse.che.exec","org.eclipse.che.terminal","org.eclipse.che.ws-agent","org.eclipse.che.ssh"],"servers":{}}}}},"defaultEnv":"myworkspace","links":[]}' http://localhost:8080/api/workspace
```

# Launching {{ site.product_mini_name }} IDE via REST API

After a workspace has been created it can be started via REST API:

#### Start a Workspace

```shell
# Start a workspace by its ID, with a given environment
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' 'http://localhost:8080/api/workspace/workspace01oqb9ptzrperis7/runtime?environment=myworkspace'
```

# Stacks API

Stacks are the templating mechanism that defines how the runtime of a workspace will be generated and started.

#### List Stacks Tagged With 'Node'

```shell  
curl --header 'Accept: application/json' http://localhost:8080/api/stack?tags=Node.JS
```

Query parameter `tags` is optional and used to narrow down search results.

It's possible to use multiple query parameters, e.g. `http://localhost:8080/api/stack?tags=Java&tags=Ubuntu`

Swagger: http://localhost:8080/swagger/#!/stack/searchStacks


#### Create a New Stack

To create a stack, you need to define its configuration according to the [stack data model]({{base}}{{site.links["ws-data-model-stacks"]}}) and send it in a POST request:

```shell  
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"name":"my-custom-stack"source":{"origin":"codenvy/ubuntu_jdk8"type":"image"},"components":[],"tags":["my-custom-stack","Ubuntu","Git","Subversion"],"id":"stack15l7wsfqffxokhle","workspaceConfig":{"environments":{"default":{"machines":{"default":{"attributes":{"memoryLimitBytes":"1048576000"},"servers":{},"agents":["org.eclipse.che.terminal","org.eclipse.che.ws-agent","org.eclipse.che.ssh"]}},"recipe":{"location":"codenvy/ubuntu_jdk8","type":"dockerimage"}}},"defaultEnv":"default","projects":[],"name":"default"commands":[],"links":[]},"creator":"che","description":"Default Blank Stack.","scope":"general"}' http://localhost:8080/api/stack

```

#### Update a Stack

You can update the stack configuration in a PUT request:

```shell  
curl -X PUT --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"name":"my-custom-stack","source":{"origin":"codenvy/ubuntu_jdk8","type":"image"},"components":[],"tags":["my-custom-stack","Ubuntu","Git","Subversion"],"id":"stacki7jf4x4n2cz6r3cr","workspaceConfig":{"environments":{"default":{"machines":{"default":{"attributes":{"memoryLimitBytes":"1048576000"},"servers":{},"agents":["org.eclipse.che.terminal","org.eclipse.che.ws-agent","org.eclipse.che.ssh"]}},"recipe":{"location":"codenvy/ubuntu_jdk8","type":"dockerimage"}}},"defaultEnv":"default","projects":[],"name":"default","commands":[],"links":[]},"creator":"che","description":"NEW-DESCRIPTION","scope":"general"}' http://localhost:8080/api/stack/${id}
```

#### Delete a Stack

To delete a stack you need to pass the stack ID as a path parameter:

```shell  
curl -X DELETE --header 'Accept: application/json' http://localhost:8080/api/stack/${id}
```
