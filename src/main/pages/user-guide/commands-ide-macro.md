---
title: "Commands and IDE Macros"
keywords: workspace, runtime, commands, build, run, macro, preview, url
tags: [workspace, runtime]
sidebar: user_sidebar
permalink: commands-ide-macro.html
folder: user-guide
---

{% include links.html %}

Commands are script-like instructions that are injected into the workspace machine for execution. Commands are saved in the configuration storage of your workspace and are part of any workspace export.

## Command Overview  

A command is defined by:

* A set of instructions to be injected into the workspace machine for execution  
* A goal to organize commands for your workflow  
* A context to scope the command to particular project(s)  
* A previewURL which to expose URL of a running server  

## Command Goals  

A command is executed by the developer to achieve a particular step from his flow. We provide the ability to organize commands per goal:
* _Build_: Commands that build a workspace’s projects.  
* _Test_: Commands related to test execution.  
* _Run_: Commands that run a workspace’s projects.  
* _Debug_: Commands used to start a debugging session.  
* _Deploy_: Commands that are used to deploy a workspace’s projects onto specific servers or services.  
* _Common_: General purpose commands.  

## Command Context  

All commands are not applicable to every project. So we wanted to add the notion of context to a command. The context of a command defines the project(s) that the command can be used with. For example: a maven build command will be relevant only if the project is using maven.

## Managing Commands  

Workspace commands are available thought the `Commands Explorer` accessible from the left pane where they are organized by goal.

{% include image.html file="commands/command-explorer.png" %}

You can create new commands by using the `+` button display next to each goals. Alternatively, you can select a command from the tree to edit, duplicate or delete it.

{% include image.html file="commands/command-editor.png" %}

The command editor is handled as another tab in the existing editor pane. You get more space to configure the command and benefit from the full screen edit mode (by double clicking on the tab) and the ability to split vertically or horizontally to display multiple editors at the same time.

- **Name**: Command name as to be unique in your workspace. The name is not restricted to camelCase.  
- **Intructions**: Learn more about instructions and [macros](#macros).  
- **Goal**: Use the dropdown to change the goal of the command.  
- **Context**: By default, the command is available with all project(s) of the workspace. You can scope the command to be available only for selected project(s).  
- **Preview**: Learn more about [previews][servers].

Che provides macros that can be used within a command or preview URL to reference workspace objects. Learn more [here](#macros).

## Macros list

When editing a command, you can get an access to all the macros that can be used in the command’s instructions or in the preview URL. To display the complete list of macros, click on the `Macros` link.

{% include image.html file="commands/command-macros-list.png" %}

## Macros Auto-Completion

You can get auto-complete for all macros used in the editor. To activate this feature hit `<Ctrl+Space>` this will bring up a menu listing all the possible macros based on what’s been typed.

{% include image.html file="commands/command-macros-autocompletion.png" %}

## Use Commands

You can use commands from multiple widgets:

* Command palette   
* Command toolbar  
* Contextual menu in project explorer  

## Command Palette

Since commands are often run in the heat of coding, you can use a hotkey to open the command palette.

{% include image.html file="commands/command-palette.png" %}

The command palette allows to quickly select a command to be executed. To call the command palette from the keyboard hit `<shift+F10>` and then use the cursor keys to navigate and enter to execute the command.

## Command Toolbar

The  command toolbar provides a way to execute the most common `Run` and `Debug` goals. It also provides access to all the executed commands and previews from a single place.

{% include image.html file="commands/command-toolbar.png" %}

**Run and Debug Buttons**

If you have commands defined for those goals, you can trigger them directly from those buttons.

If you have multiple commands defined for the `Run` goal and if it’s the first time you are using the `Run` button, you’ll be asked to choose the default command associated with the button. The next click on the button will trigger the previously selected command.

By doing a long click on the button you can select the command from the `Run` goal to execute. This command will become the default command associated with the `Run` button.

The same mechanisms apply to the `Debug` button.

**Command Controller**

The command controller allow you to see the state of the workspace and the last command executed. You can see since how long the command started and also decide if it should be stopped or relaunched.

When multiple commands have been executed it’s possible to see the list of all previously executed commands by clicking on the widget.

{% include image.html file="commands/command-toolbar-expanded.png" %}

To clean the list, remove the command's process from the list of processes.

{% include image.html file="commands/command-clean-toolbar.png" %}

**Preview Button**

If you have a command which start servers (for example, Tomcat) you can define the preview URL to access the running server. Learn more at [server preview URLs](servers.html#preview-urls).

The preview button provides quick access to all the servers that are running in workspace’s machines.


## Authoring Command Instructions  

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

## Macros  

Che provides macros that can be used within a command or preview URL to reference workspace objects. Macros are translated into real values only when used in the IDE! You cannot use macros in commands that are launched from server side.

| Macro   | Details   
| --- | ---
| `${current.project.path}`                 | Absolute path to the project or module currently selected in the project explorer tree.
| `${current.project.eldest.parent.path}`   | Absolute path to a project root (for example, in Maven multi module project)
| `${current.class.fqn}`                    | The fully qualified package.class name of the Java class currently active in the editor panel.
| `${current.project.relpath}`              | The path to the currently selected project relative to `/projects`. Effectively removes the `/projects` path from any project reference.
| `${editor.current.file.name}`             | Currently selected file in editor   
| `${editor.current.file.basename}`         | Currently selected file in editor without extension   
| `${editor.current.file.path}`             | Absolute path to the selected file in editor   
| `${editor.current.file.relpath}`          | Path relative to the `/projects` folder to the selected file in editor   
| `${editor.current.project.name}`          | Project name of the file currently selected in editor   
| `${editor.current.project.type}`          | Project type of the file currently selected in editor   
| `${explorer.current.file.name}`           | Currently selected file in project tree   
| `${explorer.current.file.basename}`       | Currently selected file in project tree without extension   
| `${explorer.current.file.path}`           | Absolute path to the selected file in project tree   
| `${explorer.current.file.relpath}`        | Path relative to the `/projects` folder in project tree   
| `${explorer.current.project.name}`        | Project name of the file currently selected in explorer   
| `${java.main.class}`                      | Path to the main class
| `${machine.dev.hostname}`                 | Current machine host name
| `${project.java.classpath}`               | Project classpath
| `${project.java.output.dir}`              | Path to Java project output dir
| `${project.java.sourcepath}`              | Path to Java project source dir
| `${explorer.current.project.type}`        | Project type of the file currently selected in explorer   
| `${server.<serverName>}`                  | Returns protocol, hostname and port of an internal server. `<port>` is defined by the same internal port of the internal service that you have exposed in your workspace recipe. <br><br> Returns the hostname and port of a service or application you launch inside of a machine. <br><br> The hostname resolves to the hostname or the IP address of the workspace machine. This name varies depending upon where Docker is running and whether it is embedded within a VM.<br><br> The port returns the Docker ephemeral port that you can give to your external clients to connect to your internal service. Docker uses ephemeral port mapping to expose a range of ports that your clients may use to connect to your internal service. This port mapping is dynamic. In case of OpenShift a route will be returned.   
| `${workspace.name}`                       | Returns the name of the workspace   
| `${workspace.namespace}`                  | Workspace namespace (defaults to `che` in single user Che)

## Environment Variables  

The workspace machine has a set of system environment variables that have been exported. They are reachable from within your command scripts using `bash` syntax.

```shell  
# List all available machine system environment variables
export

# Reference an environment variable, where $TOMCAT_HOME points to /home/user/tomcat8
$TOMCAT_HOME/bin/catalina.sh run
```
