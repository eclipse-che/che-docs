---
tags: [ "eclipse" , "che" ]
title: Java+Gradle
excerpt: ""
layout: tutorials
permalink: /:categories/gradle/
---
{% include base.html %}
Gradle is an open source build automation system that builds upon the concepts of Apache Ant and Apache Maven and introduces a Groovy-based domain-specific language (DSL) instead of the XML form used by Apache Maven of declaring the project configuration.

Che currently only _supports Gradle on the command line, but does not yet have a native project type like it does for Maven (which can inspect the dependencies list and automatically download them).  The command line configuration of Gradle means that you either use the javac or maven project type, but then configure classpath and other variables in the workspace to work with Gradle._  Please watch [issue #2669](https://github.com/eclipse/che/issues/2669) to track progress about this feature.


*Instructions - Create a New Project*
```text  
# When on the User Dashboard, create a custom stack. The recipe goes as follows:
FROM eclipse/ubuntu_gradle

# Import a project from source:
https://github.com/che-samples/console-java-gradle
```
*Instructions - Create Commands*
```text  
# In the IDE create a custom command with the following syntax to build your project:
Title:    build
Command:  cd ${current.project.path} && gradle build
Preview:  <empty>

# Create a new custom command to run your application. In this case the command syntax will be:
Title:   run
Command: java -jar ${current.project.path}/build/libs/*.jar
Preview: <empty>

#Run commands may vary depending on the application type (console, webapp etc.)
```
*Instructions - Test Your Application*
```text  
# Test your application
1. Execute `build` command.
2. After a successful project build run the `run` command.
3. See the output on the Consoles panel.
```
