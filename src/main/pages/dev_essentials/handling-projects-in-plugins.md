---
title: "Handling Projects in Server and Client Side Plugins"
keywords: framework, plugin, extension, project import, file system
tags: [extensions, dev-docs]
sidebar: user_sidebar
permalink: handling-projects-in-plugins.html
folder: dev_essentials
---

{% include links.html %}


## Overview
In Che there is a bunch of project operations that can be performed via REST, JSON-RPC or programmatically (on server side). Most valuable will be covered by this chapter.

## Project import
In is possible to import a project using several ways, Che supports project import via REST, JSON-RPC and ProjectManager, those will be described further with examples.

### Using REST to import a project
Most popular way of project import for clients is using corresponding REST service [`org.eclipse.che.api.project.server.ProjectService`](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project/src/main/java/org/eclipse/che/api/project/server/ProjectService.java). It has quite extensive API, so please check the service to have complete understanding of it's capabilities. In Eclipse Che IDE there is already implemented [`org.eclipse.che.ide.project.ProjectServiceClient`](https://github.com/eclipse/che/blob/master/ide/che-core-ide-app/src/main/java/org/eclipse/che/ide/project/ProjectServiceClient.java) that we can use in order to communicate with project service. Most basic use case is: 
```java
Path path = Path.valueOf("/DemoProject");

String location = "location";
String storage = "git";
Map<String, String> parameters = new HashMap<String, String>() {
                  {
                    put("branch", "master");
                    put("commitId", "123456");
                    put("keepVcs", "true");
                    put("fetch", "12345");
                    put("keepDir", "/src");
                  }
                }

SourceStorageDto sourceStorage = dtoFactory.createDto(SourceStorageDto.class);
sourceStorage.setLocation(location);
sourceStorage.setStorage(git);
sourceStorage.setParameters();
				
projectServiceClient.importProject(path, sourceStorage)
                    .then((ignored)->{});
```
Where:

**`path`** - project path in workspace file system

**`sourceStorage`** - source storage metadata container

**`location`** - project location in a storage (can be URL, or any other storage dependent location descriptor)

**`storage`** - storage identifier, in our example it is "git"

**`parameters`** - storage related parameters

Example can be found [here](https://github.com/eclipse/che/blob/master/ide/che-core-ide-app/src/main/java/org/eclipse/che/ide/resources/impl/ResourceManager.java#L497)

### Using JSON-RPC to import a project
Another approach is to use JSON-RPC calls instead of REST, that may be more convenient for JSON-RPC based clients. JSON-RPC service is represented by a range of JSON-RPC method handlers that are all configured within [`org.eclipse.che.api.project.server.ProjectJsonRpcServiceConfigurator`](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project/src/main/java/org/eclipse/che/api/project/server/ProjectJsonRpcServiceConfigurator.java) class and utilize JSON-RPC protocol Eclipse Che implementation. In order to import a project we must call `"project/import"` method, that has [`org.eclipse.che.api.project.shared.dto.service.ImportRequestDto`](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project-shared/src/main/java/org/eclipse/che/api/project/shared/dto/service/ImportRequestDto.java) as request params and [`org.eclipse.che.api.project.shared.dto.service.ImportResponseDto`](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project-shared/src/main/java/org/eclipse/che/api/project/shared/dto/service/ImportResponseDto.java) as a result. Inside those DTOs you will need to configure [`org.eclipse.che.api.core.model.workspace.config.SourceStorage`](https://github.com/eclipse/che/blob/master/core/che-core-api-model/src/main/java/org/eclipse/che/api/core/model/workspace/config/SourceStorage.java) in order to start import procedure and will receive [`org.eclipse.che.api.core.model.workspace.config.ProjectConfig`](https://github.com/eclipse/che/blob/master/core/che-core-api-model/src/main/java/org/eclipse/che/api/core/model/workspace/config/ProjectConfig.java) after import is finished. Most basic example is:
```java

String projectWsPath = "/DemoProject"

String method = "project/import";
String endpointId = "ws-agent";

String location = "location";
String storage = "git";
Map<String, String> parameters = new HashMap<String, String>() {
                  {
                    put("branch", "master");
                    put("commitId", "123456");
                    put("keepVcs", "true");
                    put("fetch", "12345");
                    put("keepDir", "/src");
                  }
                }

SourceStorageDto sourceStorage = dtoFactory.createDto(SourceStorageDto.class);
sourceStorage.setLocation(location);
sourceStorage.setStorage(git);
sourceStorage.setParameters();
				
				
ImportRequestDto params = dtoFactory.createDto(ImportRequestDto.class);
params.setWsPath(projectWsPath);
params.setSourceStorage(sourceStorage);

Class<?> resultClass = ImportResponseDto.class;

    requestTransmitter
        .newRequest()
        .endpointId(endpointId)
        .methodName(method)
        .paramsAsDto(params)
        .sendAndReceiveResultAsDto(resultClass)
        .onSuccess((importResponse) -> {})
		.onFailure((jsonRpcError) -> {});
```

Where:

**`method`** - JSON-RPC compliant method name that we want to call on server side, in our case it is `"project/import"`

**`endpointId`** - identifier of endpoint where we want to call our method, in our case it is `"ws-agent"`

**`projectWsPath`** - project path in workspace file system

**`resultClass`** - class of resulting dto

**`importResponse`** - import response DTO that contains business logic objects, in our case it contains imported project configuration


### Using ProjectManager to import a project
On server side we can use [`org.eclipse.che.api.project.server.ProjectManager`](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project/src/main/java/org/eclipse/che/api/project/server/ProjectManager.java) in order to perform project import operations. Most basic use case:
```java
BiConsumer<String, String> consumer = (s1, s2) -> {};

boolean rewrite = false;

String projectWsPath = "/DemoProject"

String location = "location";
String storage = "git";
Map<String, String> parameters = new HashMap<String, String>() {
                  {
                    put("branch", "master");
                    put("commitId", "123456");
                    put("keepVcs", "true");
                    put("fetch", "12345");
                    put("keepDir", "/src");
                  }
                }

SourceStorageDto sourceStorage = DtoFactory.newInstance().createDto(SourceStorageDto.class);
sourceStorage.setLocation(location);
sourceStorage.setStorage(git);
sourceStorage.setParameters();

projectManager.doImport(projectWsPath, sourceStorage, rewrite, consumer);

```

Where:

**`consumer`** - binary consumer that may accept project import progression reports as string lines and pass it further, e.g. it is used to track project import progression on clients

**`rewrite`** - boolean parameter to indicate if an old project can be rewritten by new one during import

Example can be found [here](https://github.com/eclipse/che/blob/master/wsagent/che-core-api-project/src/main/java/org/eclipse/che/api/project/server/impl/SynchronizingProjectManager.java#L227)