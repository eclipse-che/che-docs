---
tags: [ "eclipse" , "che" ]
title: Spring Boot in Che
excerpt: ""
layout: tutorials
permalink: /:categories/spring-boot/
---
{% include base.html %}
Spring Boot is Spring's convention-over-configuration solution for creating stand-alone, production-grade Spring based Applications that you can "just run". This page provides a quick configuration guide to get started with Spring Boot within Che.

*Insructions - Create a New Workspace*
```text  
# In the dashboard, create a new project and import from source:
https://github.com/che-samples/web-java-spring-boot

# Choose the Java stack.
# Create the workspace.
```

*Instructions - Create Command*
```text  
# In the IDE, create a new Maven command. Give it the syntax:
Title:    run
Command:  spring-boot:run
Preview:  http://${server.port.8080}
```

*Instructions - Test Your Application*
```text  
# Test your application
1. Run the `run` command.
2. See the application on the preview URL.

# Stopping the Spring Boot application
# In the Che terminal:
ps ax | grep java
sudo kill -9 pid
```
