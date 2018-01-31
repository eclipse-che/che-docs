---
title: Develop Your First Plugin Usign Che
sidebar: user_sidebar
keywords: dev docs, developer docs, plugins, extensions
tags: [extensions, dev-docs, assembly]
permalink: che-in-che-quickstart.html
folder: developer-guide
---

Before you dive into information on how you can [extend Che framework][framework-overview] and build your own Che [assembly][assemblies], let's install and debug your first Che plugin using Che itself.

## Run Eclipse Che

**[Install: Docker][docker]**

**[Install: OpenShift][openshift]**

## Create Workspace and Sample Extension

Search for a stack by keyword `che` and choose `che-ide-server-extension` as a sample project. This extension is both IDE and server side extension. It will bring a new menu item, an action to the IDE and a notification returned from a simple REST service.   

{% include image.html file="devel/create_extension.png" %}

## Build a Deploy Your Extension

When the project shows up in project explorer, you will find 2 main Maven modules: `assembly` (See: [Assemblies][assemblies]) and plugins (containing plugins themselves).

Execute `Traefik Start`, `Tomcat8-IDE Start`, `Deploy IDE` and `Deploy Workspace Agent` commands:

{% include image.html file="devel/commands.png" %}

* Tomcat8-IDE Start - the name speaks for itself. The command starts a Tomcat 8 server
* Traefik Start - we need some smart redirects inside a workspace. By design, the IDE tries to reach workspace master at the same host:port it is running. Since we will access the 2nd IDE instance on the same host, but a different port (it's a random port from the ephemeral port range that Docker uses to publish exposed ports)
* Deploy IDE - build ide-war module and its dependencies and packages `war` artifact and copies ide.war from `assembly-ide-war` target dir over to Tomcat's webapp
* Deploy Workspace Agent does the same with the agent war artifact

The last two commands have identical preview URLs pointing to `host:port` Tomcat 8 with two extensions is bound to. You will notice `?wsagent-ref-prefix=dev-` appended to the URL. This param is an instruction for the IDE to connect to your custom workspace agent, not the default one (this is where Traefik magic happens). Click this preview URL, and when you are in the 2nd instance of IDE, call context menu in the project explorer (right click) to find **MyAction**. Click it to see a notification with `Hello CheeAllPowerfull` message:

{% include image.html file="devel/sample_action.png" %}

## Develop and Debug Client Side

Get back to an original IDE instance and execute `GWT SDM` command which will run [GWT Super Dev Mode](http://www.gwtproject.org/articles/superdevmode.html). You can find more info about Super Dev Mode in Che at [this page](ide-extensions-gwt.html#debugging-with-super-devmode). When the compilation is completed, hit the preview URL which will display a page with further instructions. You'll have to drag 2 bookmarks to your browser's bookmarks bar. Having done that, change menu item title in `MyAction.java`:

```java
    super("My New Action", "My Action Description");
```

Return to the 2nd IDE instance, click **Dev Mode On** button and hit **Compile**. Re-compilation should take ~15 seconds. Once done, call context menu in the project explorer again to see your changes.

You can also debug your client code in the browser. In the 2nd IDE instance with your custom plugin, open `Chrome's dev console > Sources > Ctrl + P > MyAction.java`. Set a breakpoint in this class and call `My New Action` in the context menu.

{% include image.html file="devel/debug_chrome.png" %}

## Develop and Debug Server Side

Let's change response from our REST service in `MyService.java`:

```java
public String sayHello(@PathParam("name") String name) {
  return "Howdy, " + name + "!";
}
```

Select this submodule in project explorer (`plugin-serverservice-server`) and run `Build` and `Workspace Agent Hot Deploy` commands one by one that will package your extension into jar artifact and swap it (by copying) in Tomcat's `webapps/ROOT/WEB-INF/lib/` that Tomcat hot deploys it. Now return to your 2nd IDE instance, call My New Action and get an updated response from server side.

It's time to **debug** this REST service. By default, we have started Tomcat in a debug mode (`jpda run`) on port 9000 which we will use to attach Che debugger.

Open `MyService.java` and set a breakpoint on line 31 (where response is returned). Go to **Run > Edit Debug Configurations > Java > Connect to process on a workspace machine > port 9000**. Save this configuration and click Debug. You will also see this configuration at **Run > Debug**.

Return to the 2nd IDE instance and call My New Action. You will get stuck and see a loader. In the main IDE instance you will see a debugger panel:

{% include image.html file="devel/debugger.png" %}

In Variable window, click `Change variable` icon and replace the value with anything you like. Hit Resume (F9) and get back to your 2nd IDE instance to see the updated response from the REST service.

{% include links.html %}
