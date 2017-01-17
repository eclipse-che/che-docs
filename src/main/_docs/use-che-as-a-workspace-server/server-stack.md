---
tags: [ "eclipse" , "che" ]
title: Stacks
excerpt: "Manage stacks using Che REST API"
layout: docs
permalink: /:categories/stack/
---
{% include base.html %}

# List All Stacks

#### cURL - List all stacks tagged with 'Node'
```shell  
curl --header 'Accept: application/json' http://localhost:8080/api/stack?tags=Node.JS
```

Query parameter `tags` is optional and used to narrow down search results.

It's possible to use multiple query parameters, e.g. `http://localhost:8080/api/stack?tags=Java&tags=Ubuntu`

Swagger: http://localhost:8080/swagger/#!/stack/searchStacks


# Create a New Stack

To create a stack, you need to define its configuration according to the [stack data model]({{base}}{{site.links["ws-data-model-stacks"]}}) and send it in a POST request:

```shell  
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"name":"my-custom-stack"source":{"origin":"codenvy/ubuntu_jdk8"type":"image"},"components":[],"tags":["my-custom-stack","Ubuntu","Git","Subversion"],"id":"stack15l7wsfqffxokhle","workspaceConfig":{"environments":{"default":{"machines":{"default":{"attributes":{"memoryLimitBytes":"1048576000"},"servers":{},"agents":["org.eclipse.che.terminal"org.eclipse.che.ws-agent"org.eclipse.che.ssh"]}},"recipe":{"location":"codenvy/ubuntu_jdk8","type":"dockerimage"}}},"defaultEnv":"default","projects":[],"name":"default"commands":[],"links":[]},"creator":"che","description":"Default Blank Stack.","scope":"general"}' http://localhost:8080/api/stack

```

Output:
```json  
{
  "name": "my-custom-stack",
  "source": {
    "origin": "codenvy/ubuntu_jdk8",
    "type": "image"
  },
  "components": [],
  "tags": [
    "my-custom-stack",
    "Ubuntu",
    "Git",
    "Subversion"
  ],
  "id": "stackocriwhwviu1kjm2r",
  "workspaceConfig": {
    "environments": {
      "default": {
        "machines": {
          "default": {
            "attributes": {
              "memoryLimitBytes": "1048576000"
            },
            "servers": {},
            "agents": [
              "org.eclipse.che.terminal",
              "org.eclipse.che.ws-agent",
              "org.eclipse.che.ssh"
            ]
          }
        },
        "recipe": {
          "location": "codenvy/ubuntu_jdk8",
          "type": "dockerimage"
        }
      }
    },
    "defaultEnv": "default",
    "projects": [],
    "name": "default",
    "commands": [],
    "links": []
  },
  "creator": "che",
  "description": "Default Blank Stack.",
  "scope": "general"
}
```


# Update a Stack

You can update the stack configuration in a PUT request:

```shell  
curl -X PUT --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"name":"my-custom-stack","source":{"origin":"codenvy/ubuntu_jdk8","type":"image"},"components":[],"tags":["my-custom-stack","Ubuntu","Git","Subversion"],"id":"stacki7jf4x4n2cz6r3cr","workspaceConfig":{"environments":{"default":{"machines":{"default":{"attributes":{"memoryLimitBytes":"1048576000"},"servers":{},"agents":["org.eclipse.che.terminal","org.eclipse.che.ws-agent","org.eclipse.che.ssh"]}},"recipe":{"location":"codenvy/ubuntu_jdk8","type":"dockerimage"}}},"defaultEnv":"default","projects":[],"name":"default","commands":[],"links":[]},"creator":"che","description":"NEW-DESCRIPTION","scope":"general"}' http://localhost:8080/api/stack/${id}
```

Output:
```json  

{
  "name": "my-custom-stack",
  "source": {
    "origin": "codenvy/ubuntu_jdk8",
    "type": "image"
  },
  "components": [],
  "tags": [
    "my-custom-stack",
    "Ubuntu",
    "Git",
    "Subversion"
  ],
  "workspaceConfig": {
    "environments": {
      "default": {
        "machines": {
          "default": {
            "attributes": {
              "memoryLimitBytes": "1048576000"
            },
            "servers": {},
            "agents": [
              "org.eclipse.che.terminal",
              "org.eclipse.che.ws-agent",
              "org.eclipse.che.ssh"
            ]
          }
        },
        "recipe": {
          "location": "codenvy/ubuntu_jdk8",
          "type": "dockerimage"
        }
      }
    },
    "defaultEnv": "default",
    "projects": [],
    "name": "default",
    "commands": [],
    "links": []
  },
  "creator": "che",
  "description": "Default Blank Stack.",
  "scope": "general"
}
```

# Delete a Stack
To delete a stack you need to pass the stack ID as a path parameter:

```shell  
curl -X DELETE --header 'Accept: application/json' http://localhost:8080/api/stack/${id}
```

Swagger: [http://localhost:8080/swagger/#!/stack/removeStack](Swagger: http://localhost:8080/swagger/#!/stack/removeStack)
