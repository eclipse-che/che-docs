---
tags: [ "eclipse" , "che" ]
title: Workspace Data Model
excerpt: "Defines workspace configuration"
layout: docs
permalink: /:categories/data-model-workspaces/
---
{% include base.html %}

JSON workspace object defines the contents and structure of a workspace. A workspace configuration is used to define the workspace to be generated.

## Workspace Object
Workspace object representation in JSON format:
```json  
{
  "id"          : STRING,         // The workspace Id  
  "namespace"   : STRING,         // The namespace of the workspace. Workspace name is unique per namespace
  "isTemporary" : [true | false], // Indicates that workspace is temporary, i.e exists only in runtime
  "status"      : STRING,         // The status of the workspace
  "config"      : {},             // Configuration of the workspace
  "runtime"     : {},             // The runtime used by the workspace
  "attributes"  : {}              // The workspace attributes
}
```
Possible `status` values are: `STARTING`,`RUNNING`, `SNAPSHOTTING`, `STOPPING` and `STOPPED`.

## WorkspaceConfig Object

WorkspaceConfig JSON:

```json  
"workspaceConfig": {
  "name"         : STRING,    // The name of the workspace
  "description"  : STRING,    // The workspace description
  "defaultEnv"   : STRING,    // The name of env that powers this workspace
  "environments" : {},        // Map of runtime envs this workspace uses
  "projects"     : [{}],      // List of projects included in the workspace
  "commands"     : [{}]       // List of commands configured in the workspace
}
```

Every workspace can have one or more environments which are used to run the code against a stack of technology. Every workspace has exactly one environment which acts as a special "development environment", for which projects are synchronized into and developer services are injected, such as intellisense, workspace agents, SSH, and plug-ins.  

Set `defaultEnv` to the name of the environment that should act as the Docker-powered environment that powers the workspace when it boots. This name must match the name given to an object in the `environments` array. Che will create a container off of this environment when the workspace is launched.

## Environments
Each environments are constructed of one or more machines, each one is an individual container. An environment can be comprised of multiple machines that are linked together, such as when you want a database running on a different machine than your debugger.
```json  
{
  "environments": {
    "name": {
      "machines" : {}, // Map of machines configurations
      "recipe"   : {}  // The recipe (the main script) to define this environment
    }
  }  
}
```

### Recipe object

```json  
 {
   "recipe" : {
     "contentType" : STRING, //  Content type of the environment recipe
     "type"        : STRING, //  Type of the environment
     "content"     : STRING, //  Content of an environment recipe
     "location"    : STRING  //  Location of an environment recipe
   }
 }
```
 Content and location fields are mutually exclusive, i.e. only one can be present.
 The source of a machine configuration object is supporting several types when using `docker` as machine configuration type, here are the supported source options:
 - `dockerfile`: to provide a link to a Dockerfile recipe or directly the content of a Dockerfile.
 - `composetype`: to provide link to a Composefile or directly the content of the Composefile recipe.
 - `dockerimage`: to provide a built Docker image.

 See more details below.

#### Dockerfile type  
It provides a docker runtime. The Dockerfile recipe can be provided by a link, using `location` field or by providing directly the content of the Dockerfile, using `content` field.
```json
 {
   "recipe": [
     {
       "content"     : STRING,
       "type"        : "dockerfile",
       "contentType" : "application/x-dockerfile"
     }
   ]
 }
```

Examples:
```json
"recipe" : {
    "type"    : "dockerfile",
    "location": "http://codenvy.io/api/recipe/recipec0v4ta2uz6jok0bn/script"
}
```
or
```json
"recipe": {
    "type"   : "dockerfile",
    "content": "FROM eclipse/ubuntu_jdk8
                RUN echo hello world
                ENV MYCUSTOM=VALUE"
}
```


#### Compose type
It provides a multi-machine runtime from a compose definition that need to be built into image(s) or reference already-built image(s) docker runtime.

```json
 {
   "recipe": {
      "content"     : STRING,
      "contentType" : "application/x-yaml",
      "type"        : "compose"
   }
 }   
```

Examples:
```json
"recipe" : {
    "type"    : "compose",
    "location": "http://beta.codenvy.com/api/recipe/recipec0v4ta2uz6jok0bn/script"
}
```
or
```json
"recipe" : {
        "contentType": "application/x-yaml",
        "type"       : "compose",
        "content"    : "services:\n  db:\n    image: mysql\n    environment:\n      MYSQL_ROOT_PASSWORD: password\n      MYSQL_DATABASE: petclinic\n      MYSQL_USER: petclinic\n      MYSQL_PASSWORD: password\n    mem_limit: 1073741824\n  dev-machine:\n    image: eclipse/ubuntu_jdk8\n    mem_limit: 2147483648\n    depends_on:\n      - db\n"
      }
}
```


#### Dockerimage type
Use `dockerimage` to provide use a Docker image.

```json
 {
   "recipe": {
      "location" : "eclipse/ubuntu_jdk8"",
      "type"     : "dockerimage"
   }
 }   
```


### Machines map
Additional information about machine(s) which is needed for purposes of Che.
MUST contain one machine with name `dev-machine`, and, optionally, additional machines.
```json
 {
   "machines": {
      "db": {
        "servers"    : {},
        "agents"     : [STRING]
        "attributes" : {}
      },
      "dev-machine": {
        "servers"    : {},
        "agents"     : [STRING],
        "attributes" : {}
      }
    }
   }
 }     
```      

#### Server Object
Describes configuration of servers that can be started inside of machine.
```json
{
 "servers": {
    "myserver" : {
     "port"       : STRING, // Port description of this server. Example: "9090/udp"
     "protocol"   : STRING, // Protocol for configuring preview url of this server.
     "properties" : {}      // Server properties
     }
  }
}
```

Example:
```json
"servers":{
  "8080/tcp":{
     "url":"http://172.17.0.1:32832",
     "ref":"tomcat8",
     "properties":{
       "internalUrl":"http://172.17.0.1:32832",
       "internalAddress":"172.17.0.1:32832"
     },
     "address":"172.17.0.1:32832",
     "protocol":"http"
  },
  "9876/tcp":{
     "url":"http://172.17.0.1:32831",
     "ref":"codeserver",
     "properties":{
       "internalUrl":"http://172.17.0.1:32831",
       "internalAddress":"172.17.0.1:32831"
     },
     "address":"172.17.0.1:32831",
     "protocol":"http"
   }
}
```


## Runtime Object
Present only in workspaces which state is `RUNNING`.
```json
{
  "runtime" : {
     "activeEnv"  : STRING, // Active environment name
     "rootFolder" : STRING, // The base folder for the workspace projects
     "devMachine" : {},     // Describes development machine only if its status is `RUNNING`
     "machines"   : [{}]    // All the machines which statuses are `RUNNING`
  }
}      
```

### DevMachine object
Represents running machine configuration.
```json
{
  "devMachine":{
     "envName"     : STRING, // Name of environment that started this machine
     "id"          : STRING, // Machine identifier
     "owner"       : STRING, // Machine owner (user identifier)
     "status"      : STRING, // Runtime status of the machine
     "runtime"     : {},     // Runtime information about machine
     "config"      : {},     // Configuration used to create this machine
     "workspaceId" : STRING  // ID of workspace this machine belongs to
  }
}
```

#### MachineRuntimeInfo object
Represents running machine properties and variables.
```json
 {
   "runtime":{
      "projectsRoot" : STRING, // Projects root path
      "properties"   : {},     // Machine specific properties map
      "envVariables" : {},     // Map of environment variables of machine
      "servers"      : {}      // Mapping of exposed ports.
   }
}
```

#### Runtime Servers object map
Describes configuration of servers that is started inside of machine.
```json
{
 "servers":{
    "4401/tcp":{
      "url"        : STRING,   // Full url to this server. Example: "http://172.17.0.1:32836/api"
      "ref"        : STRING,   // Ref string
      "properties" : {},       // Properties
      "address"    : STRING,  // Adress. Example: "172.17.0.1:32836"
      "protocol"   : STRING   // Server protocol. Example: "http"
    },
    "8080/tcp":{
       "url"       : STRING,
       "ref"       : STRING
       ...
   }
}
```
