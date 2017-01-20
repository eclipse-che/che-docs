---
tags: [ "eclipse" , "che" ]
title: Workspaces
excerpt: "cURL code that shows how to create a workspace with REST API"
layout: docs
permalink: /:categories/create-workspaces/
---
{% include base.html %}

Sample cURL code that creates a workspace named `workspace-debian` and displays resulting data in console:

#### cURL - Create a workspace  

```shell  
# use of http://localhost:8080/api/workspace
curl -X POST -H 'Content-Type: application/json' -d '{"environments":{"workspace-debian":{"name":"workspace-debian"recipe":null,"machineConfigs":[{"name":"ws-machine"limits":{"memory":1000},"type":"docker"source":{"location":"http://localhost:8080/ide/api/recipe/recipe_debian/script"type":"recipe"},"dev":true}]}},"name":"workspace-debian"attributes":{},"projects":[],"defaultEnvName":"workspace-debian"description":null,"commands":[],"links":[]}' http://localhost:8080/api/workspace/config?account=che
```

# Launching {{ site.product_mini_name }} IDE via REST API  
After a workspace has been created it can be started via REST API:

#### cURL - Start a workspace

```shell  
# Start a workspace by its name, with a given environment
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' 'http://localhost:8080/api/workspace/name/workspace-debian/runtime?environment=workspace-debian'
```
