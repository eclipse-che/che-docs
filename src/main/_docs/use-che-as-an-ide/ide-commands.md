---
tags: [ "eclipse" , "che" ]
title: Commands
excerpt: ""
layout: docs
permalink: /:categories/commands/
---
{% include base.html %}
Commands are script-like instructions that are injected into the workspace machine for execution.
Commands are saved in the configuration storage of your workspace and are part of any workspace export.

# Command Overview  
A command is defined by:
- A set of instructions to be injected into the workspace machine for execution  
- A goal to organize commands for your workflow  
- A context to scope the command to particular project(s)  
- A previewURL which to expose URL of a running server  

## Command Goals  
A command is executed by the developer to achieve a particular step from his flow. We provide the ability to organize commands per goal:
- _Build_: commands that build a workspace’s projects.  
- _Test_: commands related to test execution.  
- _Run_: commands that run a workspace’s projects.  
- _Debug_: commands used to start a debugging session.  
- _Deploy_: commands that are used to deploy a workspace’s projects onto specific servers or services.  
- _Common_: general purpose commands.  

## Command Context  
All commands are not applicable to every project. So we wanted to add the notion of context to a command. The context of a command defines the project(s) that the command can be used with. For example: a maven build command will be relevant only if the project is using maven.

# Managing commands  
Workspace's commands are available thought the `Commands Explorer` accessible from the left pane where they are organized by goal.

![command-explorer.png]({{base}}{{site.links["command-explorer.png"]}}){:style="width: 40%"}  

You can create new commands by using the `+` button display next to each goals.
Alternatively, you can select a command from the tree to edit, duplicate or delete it.

![command-editor.png]({{base}}{{site.links["command-editor.png"]}})

The command editor is handled as another tab in the existing editor pane. You get more space to configure the command and benefit from the full screen edit mode (by double clicking on the tab) and the ability to split vertically or horizontally to display multiple editors at the same time.

- **Name**: Command name as to be unique in your workspace. The name is not restricted to camelCase.  
- **Intructions**: Learn more about instructions and [macros]({{base}}{{site.links["ide-commands"]}}#macros).  
- **Goal**: Use the dropdown to change the goal of the command.  
- **Context**: By default, the command is available with all project(s) of the workspace. You can scope the command to be available only for selected project(s).  
- **Preview**: Learn more about [previews]({{base}}{{site.links["ide-previews"]}}).  


## Macros hints
{{ site.product_mini_name }} provides macros that can be used within a command or preview URL to reference workspace objects. Learn more [here]({{base}}{{site.links["ide-commands"]}}#macros).

#### Macros list

When editing a command, you can get an access to all the macros that can be used in the command’s instructions or in the preview URL. To display the complete list of macros, click on the `Macros` link.

![command-macros-list.png]({{base}}{{site.links["command-macros-list.png"]}})

#### Macros auto-completion

You can get auto-complete for all macros used in the editor. To activate this feature hit `<ctrl+space>` this will bring up a menu listing all the possible macros based on what’s been typed.

![command-macros-autocompletion.png]({{base}}{{site.links["command-macros-autocompletion.png"]}})


# Use commands
You can use commands from multiple widgets:
- Command palette   
- Command toolbar  
- Contextual menu in project explorer  

## Command Palette
Since commands are often run in the heat of coding, you can use a hotkey to open the command palette.

![command-palette.png]({{base}}{{site.links["command-palette.png"]}}){:style="width: 40%"}  


The command palette allows to quickly select a command to be executed.
To call the command palette from the keyboard hit `<shift+F10>` and then use the cursor keys to navigate and enter to execute the command.

## Command Toolbar

The  command toolbar provides a way to execute the most common `Run` and `Debug` goals. It also provides access to all the executed commands and previews from a single place.

![command-toolbar.png]({{base}}{{site.links["command-toolbar.png"]}})

**Run and Debug Buttons**
If you have commands defined for those goals, you can trigger them directly from those buttons.

If you have multiple commands defined for the `Run` goal and if it’s the first time you are using the `Run` button, you’ll be asked to choose the default command associated with the button. The next click on the button will trigger the previously selected command.

By doing a long click on the button you can select the command from the `Run` goal to execute. This command will become the default command associated with the `Run` button.

The same mechanisms apply to the `Debug` button.

**Command Controller**
The command controller allow you to see the state of the workspace and the last command executed. You can see since how long the command started and also decide if it should be stopped or relaunched.

When multiple commands have been executed it’s possible to see the list of all previously executed commands by clicking on the widget.

![command-toolbar-expanded.png]({{base}}{{site.links["command-toolbar-expanded.png"]}})

To clean the list, remove the command's process from the list of processes.

![command-clean-toolbar.png]({{base}}{{site.links["command-clean-toolbar.png"]}})

**Preview Button**
If you have a command which start servers (for example, Tomcat) you can define the preview URL to access the running server. Learn more [here]({{base}}{{site.links["ide-previews"]}}).

The preview button provides quick access to all the servers that are running in workspace’s machines.




# Authoring Command Instructions  
A command may contain a single instruction or a succession of commands. For example:

```shell  
# each command starts from a new line
cd /projects/spring
mvn clean install

# a succession of several commands where `;` stands for a new line
cd /projects/spring; mvn clean install

# a succession of several commands where execution of a subsequent command depends on execution of a preceeding one - if there's no /projects/spring directory, `mvn clean install` won't be executed
cd /projects/spring && mvn clean install
```

It is possible to check for conditions, use for loops and other bash syntax:

```shell  
# copy build artifact only if build is a success
mvn -f ${current.project.path} clean install
  if [[ $? -eq 0 ]]; then
    cp /projects/kitchensink/target/*.war /home/user/wildfly-10.0.0.Beta2/standalone/deployments/ROOT.war
    echo "BUILD ARTIFACT SUCCESSFULLY DEPLOYED..."
else
    echo "FAILED TO DEPLOY NEW ARTIFACT DUE TO BUILD FAILURE..."
fi
```

# Macros  
{{ site.product_mini_name }} provides macros that can be used within a command or preview URL to reference workspace objects.

| Macro   | Details   
| --- | ---
| `${current.project.path}` | Absolute path to the project or module currently selected in the project explorer tree.
| `${current.class.fqn}` | The fully qualified package.class name of the Java class currently active in the editor panel.
| `${current.project.relpath}` | The path to the currently selected project relative to `/projects`. Effectively removes the `/projects` path from any project reference.
| `${editor.current.file.name}` | Currently selected file in editor   
| `${editor.current.file.path}` | Absolute path to the selected file in editor   
| `${editor.current.file.relpath}` | Path relative to the `/projects` folder to the selected file in editor   
| `${editor.current.project.name}` | Project name of the file currently selected in editor   
| `${editor.current.project.type}` | Project type of the file currently selected in editor   
| `${explorer.current.file.name}` | Currently selected file in project tree   
| `${explorer.current.file.path}` | Absolute path to the selected file in project tree   
| `${explorer.current.file.relpath}` | Path relative to the `/projects` folder in project tree   
| `${explorer.current.project.name}` | Project name of the file currently selected in explorer   
| `${explorer.current.project.type}` | Project type of the file currently selected in explorer   
| `${server.<port>}` | Returns protocol, hostname and port of an internal server. `<port>` is defined by the same internal port of the internal service that you have exposed in your workspace recipe. <br><br> Returns the hostname and port of a service or application you launch inside of a machine. <br><br> The hostname resolves to the hostname or the IP address of the workspace machine. This name varies depending upon where Docker is running and whether it is embedded within a VM.  See [Networking]({{base}}{{site.links["setup-configuration"]}}). <br><br> The port returns the Docker ephemeral port that you can give to your external clients to connect to your internal service. Docker uses ephemeral port mapping to expose a range of ports that your clients may use to connect to your internal service. This port mapping is dynamic.   
| `${server.<port>.port}` | Returns resolved port of a server registered by internal port  
| `${server.<port>.protocol}` | Returns protocol of a server registered by internal port  
| `${server.<port>.hostname}` | Returns hostname of a server registered by internal port  
| `${server.port.<port>}` | Returns the hostname and port of a service or application you launch inside of a machine. <br><br>The hostname resolves to the hostname or the IP address of the workspace machine. This name varies depending upon where Docker is running and whether it is embedded within a VM. See [Networking]({{base}}{{site.links["setup-configuration"]}}).<br><br>The port returns the Docker ephemeral port that you can give to your external clients to connect to your internal service. Docker uses ephemeral port mapping to expose a range of ports that your clients may use to connect to your internal service. This port mapping is dynamic.<br><br>Let's say you launched a process inside your machine and bound it to `<port>`. A remote client can connect to your workspace by taking the IP address of the machine and the port of your service. Docker provides a dynamic port number to external clients for each service running internally. This macro will return the value Docker assigned for external clients to use. <br><br>For example, in your workspace, you launch a service that binds to port 8080. Then `${server.port.8080}` macro may return 32769, which is the port to give to remote clients to connect to the internal service.   
| `${workspace.name}` | Returns the name of the workspace   


# Machine Environment Variables  
The workspace machine has a set of system environment variables that have been exported. They are reachable from within your command scripts using `bash` syntax.

```shell  
# List all available machine system environment variables
export

# Reference an environment variable, where $TOMCAT_HOME points to /home/user/tomcat8
$TOMCAT_HOME/bin/catalina.sh run
```
