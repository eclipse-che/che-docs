---
tags: [ "eclipse" , "che" ]
title: Debug
excerpt: ""
layout: docs
permalink: /:categories/debug/
---
{% include base.html %}

 Debuggers are included in Che for:
  * [Java](#java)
  * [C/C++](#gdb) (via GDB)
  * [PHP](#php) (via Zend debugger, zDebug and Z-Ray)
  * [Node.js](#nodejs) (via GDB)
  
# Java  
Java debugger is deployed with the workspace agent, i.e. runs in the workspace. It can connect to local processes (those running in a workspace) or remote ones.

Breakpoints are set with a single click on a line number in the editor. You can set breakpoints before attaching a debugger:

![breakpoint.png]({{base}}{{site.links["breakpoint.png"]}})

In a Debug Dialog (**Run > Edit Debug Configurations...**), choose if you want to attach to a process in a local workspace or a remote machine. If localhost is chosen, a drop down menu will show all ports that are exposed in a container. You may either choose an existing port or provide your own.

![debug-configurations.png]({{base}}{{site.links["debug-configurations.png"]}})

## Java Console Apps

To debug console apps, pass debug arguments to JVM:
```shell  
mvn clean install && java -jar -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y ${current.project.path}/target/*.jar
```
## Java Web Apps

To debug a web application, you need to start a web server in a debug mode. Debug arguments may vary depending on the web server in use. For example, to start Tomcat in a debug mode, run:
```text  
$TOMCAT_HOME/bin/catalina.sh jpda run
```
You can add debug commands to CMD widget to permanently save them with the workspace config.
# GDB  
GDB can be used to debug **C/C++** and **Node.js** projects.

## Debugging Local Binary

Compile your app with `-g` argument, go to `Run > Edit Debug Configurations > GDB`. Create a new configuration, check `Debug local binary` box. By default, binary path is `${current.project.path/a.out}`. When the debugger attaches, this macro is translated into an absolute path to a currently selected project. `a.out` is the default binary name. If you have compiled binary with a different name, change it:
![debug.png]({{base}}{{site.links["debug.png"]}})
Set a breakpoint in code, go to `Run > Debug > YourDebugConfiguration`. Once a debugger attaches, there's a notification in the top right corner. A debugger panel will open.

## Remote Debugging with GDB server

Similar to Java debugger, one needs to start a process that a debugger will connect to. In case of GDB, this is `gdbserver` which is installed in C/CPP runtime by default.

To **run** gdbserver, execute the following:

`gdbserver :$port /path/to/binary/file` where `$port` is a random port that you will then connect to. It is important to provide an absolute path to a binary file if you run gdbserver in a command.

It is important to make sure that the binary has been compiled with `-g` argument, i.e. with attached sources.

When gdbserver starts, it produces some output with info on process ID and port it's listening on. When a remote client connects to gdbserver, there will be a message with IP address of a remote connection.

To **stop** gdbserver, terminate the command in Consoles panel (if the server has been started as a command). If gdbserver has been started in a terminal, Ctrl+C does not kill it. Open another terminal into a machine, and run:

`kill $(ps ax | grep "[g]dbserver" | awk {'print $1;}')`

This commands grabs gdbserver PID and kills the process.

## Connect to GDB server

Go to `Run > Edit Debug Configurations` and enter host (localhost if gdbserver has been started in the same workspace environment), port and path to the binary file being debugged. By default, binary name is `a.out`. If you have compiled your binary with `-o` argument, you need to provide own custom binary name in a debug configuration.

Save your configuration, choose it at `Run > Debug > <YourDebugConfiguration>` and attach the debugger, having previously set breakpoints in source files.

### Connection Timeouts

Latency or poor connectivity may cause issues with remote debugging. A local GDB may fail to receive a timely response from the remote server. To fix it, set a default timeout for a local GDB. In the terminal, run:

`echo  "set remotetimeout 10" > ~/.gdbinit`

You may set a bigger timeout, say, 20 seconds, if there are serious connectivity issues with a remote GDB server.

It is also possible to add this command as a Dockerfile instruction for a custom recipe:

```shell  
FROM eclipse/cpp_gcc
RUN echo  "set remotetimeout 10" > /home/user/.gdbinit
```

# PHP

The PHP and Zend stacks come with the Zend Debugger module installed and configured. Debugging both PHP CLI scripts and PHP web apps is supported.

The debugging workflow involves the following steps:

1. Launch the Zend Debugger Client to start listening for new debug sessions.
1. Optionally set breakpoints in the PHP editor.
1. Trigger a debug session from the CLI script or the web app.
1. Use the Web IDE tooling to do the actual debugging.

![php-debugging.gif]({{ base }}{{ site.links["php-debugging.gif"] }})

## Starting the Zend Debugger Client

{{site.product_formal_name}} has the Zend Debugger Client integrated in the Web IDE. For launching the Zend Debugger Client:

1. Go to `Run > Edit Debug Configurations` from the main menu.
1. Create new `PHP` configuration.
1. Change any settings if necessary. The defaults are usually OK.
1. Click the `Debug` button.

![php-debug-configuration.png]({{ base }}{{ site.links["php-debug-configuration.png"] }})

The successful launch of the Zend Debugger Client is noted with a notification message. From this moment on the Zend Debugger Client listens for new debug sessions initiated by the Zend Debugger module of the PHP engine.

The Debug Configuration window allows the following configuration for the Zend Debugger Client:

- `Break at first line`. Determines whether to break the execution at the very first line, hit by the PHP interpreter. Enabled by default. It is useful to easily find the app's entry point. You may want to switch this option off if you defined your own breakpoint and you are not interesting at breaking the execution at the first line.
- `Client host/IP`. The host/IP on which to bind the server socket for listening for new debug sessions. The default host is `localhost`. Changing it should be only necessary if the PHP engine is running in a different workspace machine or outside of the {{site.product_mini_name}} workspace at all.
- `Debug port`. The port on which to bind the server socket for listening for new debug sessions. The default port is `10137`. It should be rarely necessary to change it.
- `Use SSL encryption`. Whether to use SSL encryption for the debugging communication between the PHP engine and the Zend Debugger Client. Disabled by default.

## Debugging PHP CLI Scripts

PHP CLI scripts can be debugged by setting the `QUERY_STRING` environment variable when executing the PHP script. For example, to debug the `hello.php` script you should execute the following command in the Terminal:

```sh
QUERY_STRING="start_debug=1&debug_host=localhost&debug_port=10137" php hello.php
```

Let's dissect the value of the `QUERY_STRING`:

- `start_debug=1` says the PHP engine that we want to trigger a debug session for this execution.
- `debug_host=localhost` says that the Zend Debugger Client runs on localhost (on the same host where the PHP engine runs).
- `debug_port=10137` says that the Zend Debugger Client listens on port 10137.

For convenience the PHP and Zend stacks have the `debug php script` command. It will run the PHP script, which is currently opened in the editor, with the required `QUERY_STRING` preprended to the launch command. It is a handy way for easily debugging CLI script without the need to remember the exact `QUERY_STRING` variable.

## Debugging PHP Web Apps

Debugging web apps is done in a similar way. The value of the `QUERY_STRING` used for debugging CLI scripts must be added as a query string to the URL of the debugged web page. This can be done either manually or by using a browser toolbar/extension that does it automatically. Such browser extensions also make it easier to debug POST requests.

### Using Query Params in the URL

The `?start_debug=1&debug_host=localhost&debug_port=10137` query string must be added to the URL. For example, to debug the `http://localhost:32810/web-php-simple/index.php` web page you should request the following URL in the browser:

```
http://localhost:32810/web-php-simple/index.php?start_debug=1&debug_host=localhost&debug_port=10137
```

### Using the zDebug Extension for Chrome

The [zDebug](https://chrome.google.com/webstore/detail/zdebug/gknbnafalimbhgkmichoadhmkaoingil) extension can be used for easier triggering of debug sessions from the Chrome browser. The [Zend Debugger Extension](https://chrome.google.com/webstore/detail/zend-debugger-extension/aonajadpeeaijblinaeohfdmbgdpibba) is another extension that does the same job.

It is important to configure the Chrome extension properly before using it for debugging PHP apps running in a {{site.product_mini_name}} workspace:

1. Set `Debug Host` to `localhost` or `127.0.0.1`.
1. Set `Debug Port` to `10137`.
1. Set `Debug Local Copy` to `No`.

Note that it is not the browser that opens the debug session to the Zend Debugger Client. This is done by the PHP engine that runs in the {{site.product_mini_name}} workspace. The browser just tells the PHP engine to do so. So the above settings are for the PHP engine (the Zend Debugger module in particular). Thus the `Debug Host` must be set to `localhost` and not the public host of the docker container running the {{site.product_mini_name}} workspace.

In the end the zDebug settings should look like this:

![zdebug-settings.png]({{ base }}{{ site.links["zdebug-settings.png"] }})

Now you are ready to trigger the debug session:

1. Open the web page to debug.
1. Click on the zDebug toolbar button.
1. Click on `This Page`.

### Using the Zend Debugger Toolbar for Firefox

The [Zend Debugger Toolbar for Firefox](https://addons.mozilla.org/firefox/addon/zend-debugger-toolbar/) can be used for easier triggering of debug sessions from the Firefox browser.

After installing it, go to `Extra Stuff > Setttings` to configure the toolbar:

1. Disable the `Debug Local Copy` option.
1. Switch the `Client/IDE Settings` to `Manual Settings`.
1. Set `Debug Port` to `10137`.
1. Set `IP Address` to `127.0.0.1`.

In the end the toolbar settings should look like this:

![zend-debugger-firefox-settings.png]({{ base }}{{ site.links["zend-debugger-firefox-settings.png"] }})

Now you are ready to trigger the debug session:

1. Open the web page to debug.
1. Click on the `Debug` toolbar button.

### Using Z-Ray

[Z-Ray](http://www.zend.com/en/products/server/z-ray) is a productivity tool, part of [Zend Server](http://www.zend.com/en/products/zend_server), that is available in the Zend stack. Z-Ray requires no installation or configuraton. It is injected into the response coming from your PHP app and shown right in the browser you are using for development. 

Among other features, it also has the capability to trigger a debug session:

1. Click on the "bug" button.
1. Click on `Debug current page`.

![z-ray-debug.png]({{ base }}{{ site.links["z-ray-debug.png"] }})

That's all!

# NodeJS

The Node.js ready-to-go [stack]({{ base }}{{ site.links["ws-stacks"] }}) comes with a Node.js debugger module installed and configured. The Dockerfile is located in the [eclipse/che-dockerfiles](https://github.com/eclipse/che-dockerfiles/blob/master/recipes/node/latest/Dockerfile) repository.

The debugging workflow is:

1. Launch the Node.js debugger client to start a debug session
1. Create/Run command to generate a preview URL
1. Click the preview URL to interact with the app
1. Use the debugger panel to perform debug functions

You can set breakpoints in the editor at any time by clicking on the line number.

## Starting the Node.js Debugger Client

{{site.product_formal_name}} has the Node.js client integrated in the web IDE. to launch the debugger client:

1. Go to `Run > Edit Debug Configurations` from the main menu
1. Create a new `NODEJS` configuration
1. Change any settings if necessary. The defaults are usually OK
1. Click the `Debug` button
1. The debugger will break at first line of code

![debug-nodejs-config.png]({{ base }}{{ site.links["debug-nodejs-config.png"] }})

### Creating a Command to View the Preview URL

{{site.product_formal_name}}'s workspaces have machine(s) that are docker container(s). Docker container's exposed ports are given an emphemerial port. The preview url provides an easy way convert an internal port to it's external emphemerial port counter part.

1. Add a command `Run > Edit Commands` 
1. Give the command a name like "View Preview URL"
1. Add a fictitious command `echo` for required command line
1. Provide the preview URL for your app such as `http://${server.port.<port>}/`

### Using the Node.js Debugger

1. Start the debugger `Run > debug > <config-name>`
1. Click the continue button until server is running
1. Add breakpoints if needed
1. Run the preview URL command (see above)
1. Click the preview URL to open web app in another tab
1. Go back to IDE tab
1. Use the Web IDE tooling to do the actual debugging

![nodejs-debugger-walkthru.gif]({{ base }}{{ site.links["nodejs-debugger-walkthru.gif"] }})
