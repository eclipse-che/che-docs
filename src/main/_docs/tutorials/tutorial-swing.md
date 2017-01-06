---
tags: [ "eclipse" , "che" ]
title: Java Swing in Che
excerpt: ""
layout: tutorials
permalink: /:categories/swing/
---
{% include base.html %}
Swing is a GUI widget toolkit for Java. It is part of Oracle's Java Foundation Classes (JFC) – an API for providing a graphical user interface (GUI) for Java programs.

*Instructions - Create a New Project*
```text  
# Create your own custom stack. The recipe goes as follows
FROM codenvy/ubuntu_jdk8_x11

# Import a project from source:
https://github.com/codenvy-templates/desktop-swing-java-basic
```

*Instructions - Build a Swing Project*
```text  
# In the IDE create a Maven command with the following syntax to build your project:
Title:    build
Working directory: ${current.project.path}
Command:  clean install
Preview:  http://${server.port.6080}
```

*Instructions - Start a Swing Project*
```text  
# In the noVNC window right mouse click to call the Terminal. Go to `projects/{your-project-name}/target` directory and start your project:

java -jar {your-artifact-name}.jar
```

*Instructions - Test Your Application*
```text  
# Test your application
1. Click Get Greeting tab to call the info box.
2. Exit.
3. Go to the IDE and make some changes to the app.
4. Rerun `build` command.
5. Click Preview URL, cd /projects/{your-project-name}/target directory again and run `java -jar {your-project-name}.jar` command to see changes.
```

If you want to debug your app, find instructions on [Java debugger]({{base}}{{site.links["ide-debug"]}}).
