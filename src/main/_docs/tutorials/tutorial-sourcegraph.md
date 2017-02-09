---
tags: [ "eclipse" , "che" ]
title: Sourcegraph
excerpt: ""
layout: tutorials
permalink: /:categories/sourcegraph/
---
{% include base.html %}
Sourcegraph is a version-control platform built with Code Intelligence.

*Instructions - Create a New Workspace*
```shell  
# In the dashboard create a new custom Stack option. Use the following image:
FROM codenvy/sourcegraph

# Create a new project, use the newly created stack and import from source:
https://src.sourcegraph.com/sourcegraph

# Name the project `sourcegraph` (this should be the **exact** name since it is then used in commands and `GOPATH`)
```

*Instructions - Create Command*
```shell  
# Open Command Widget and create a custom command:
Title: run

Command: mkdir -p $GOPATH/src/src.sourcegraph.com/sourcegraph 2>/dev/null;  mv -v $GOPATH/* $GOPATH/src/src.sourcegraph.com/sourcegraph 2>/dev/null; sudo su - postgres -c '/usr/lib/postgresql/9.4/bin/pg_ctl -D /var/lib/postgresql/db -l /var/lib/postgresql/logfile start' && cd $GOPATH/src/src.sourcegraph.com/sourcegraph && make dep && make serve-dev

Preview: http://${server.port.3080}
```

*Instructions - Test Your Application*
```text  
# Test your application
1. Open /src/src.sourcegraph.com/sourcegraph
2. Make some edits
3. Run the `run` command.
5. You can refresh the web app in the preview URL to see your changes.
```
