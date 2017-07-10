---
tags: [ "eclipse" , "che" ]
title: Previews
excerpt: ""
layout: docs
permalink: /:categories/previews/
---
{% include base.html %}
Preview objects are URLs that reference specific files or endpoints activated by your project when you run a [command]({{base}}{{site.links["ide-commands"]}}). For example, you may have a command to start a Spring application server and deploy your project's artifacts into the application server. A preview object can be used to present the user with the URL of the deployed application.

# Create  
Preview objects are stored as part of command. {{ site.product_mini_name }} will generate the preview URL during the command execution and present the URL to the user as part of the command output. You can add a preview URL of any format within the command editor.

![command-preview.png]({{base}}{{site.links["command-preview.png"]}})

The preview object will dynamically determine the appropriate URL when the command is run.

![Capture_preview.PNG]({{base}}{{site.links["Capture_preview.PNG"]}})

## Preview Macros

When authoring a command, the following preview macros can be used:

| Macro   | Details
| --- | ---
| `${server.<port>}` | Returns protocol, hostname and port of an internal server. `<port>` is defined by the same internal port of the internal service that you have exposed in your workspace recipe. <br><br> Returns the hostname and port of a service or application you launch inside of a machine. <br><br> The hostname resolves to the hostname or the IP address of the workspace machine. This name varies depending upon where Docker is running and whether it is embedded within a VM.  See [Networking]({{base}}{{site.links["setup-configuration"]}}). <br><br> The port returns the Docker ephemeral port that you can give to your external clients to connect to your internal service. Docker uses ephemeral port mapping to expose a range of ports that your clients may use to connect to your internal service. This port mapping is dynamic.
| `${server.<port>.port}` | Returns resolved port of a server registered by internal port  
| `${server.<port>.protocol}` | Returns protocol of a server registered by internal port  
| `${server.<port>.hostname}` | Returns hostname of a server registered by internal port  
| `${server.port.<port>}` | Returns the hostname and port of a service or application you launch inside of a machine. <br><br>The hostname resolves to the hostname or the IP address of the workspace machine. This name varies depending upon where Docker is running and whether it is embedded within a VM. See [Networking]({{base}}{{site.links["setup-configuration"]}}).<br><br>The port returns the Docker ephemeral port that you can give to your external clients to connect to your internal service. Docker uses ephemeral port mapping to expose a range of ports that your clients may use to connect to your internal service. This port mapping is dynamic.<br><br>Let's say you launched a process inside your machine and bound it to `<port>`. A remote client can connect to your workspace by taking the IP address of the machine and the port of your service. Docker provides a dynamic port number to external clients for each service running internally. This macro will return the value Docker assigned for external clients to use. <br><br>For example, in your workspace, you launch a service that binds to port 8080. Then `${server.port.8080}` macro may return 32769, which is the port to give to remote clients to connect to the internal service.

There is one mandatory requirement - an internal port gets published to an external one only if it is exposed in a container. There are several methods to achieve it:

### Custom stack

```
FROM eclipse/node
EXPOSE 1001
```

In the above example, port 1001 is exposed, so when a container starts it will be published to a random port from the ephemeral port range. The preview macro for a server bound to port `1001` would be `${server.port.1001}` which will be translated into an actual preview URL when a command containing such a preview macro is executed.

Having exposed a custom port, you can get your preview URL either with a preview macro when executing a command, or in User Dashboard (see below).


### Servers in User Dashboard

All ports exposed in a container are automatically published to random ports from the ephemeral port range. You can find all of them in User Dashboard when your workspace is running.

If the port your server binds itself to is missing, you can add it:

![dashboard-servers.png]({{base}}{{site.links["dashboard-servers.png"]}})

You can add servers for a running and stopped workspace. If a workspace is running, it will be restarted for changes to be applied.

# Access Previews
From the command toolbar, you can get a quick access to all the severs that are running in your workspace's machines.

![command-toolbar.png]({{base}}{{site.links["command-toolbar.png"]}})

Preview URLs are temporary and valid for one workspace session.

# Troubleshooting

## I cannot find the required port in Dashboard and macro isn't translated into an actual URL

Port isn't exposed. Either create a custom stack and expose it, or add a server in User Dashboard (see above).

## I got the preview URL but there's nothing there

Exposed ports are published to random ports from the ephemeral port range which is `32768-65535`. Make sure thus port isn't filtered in your network for outbound connections.

It is also possible that a server running in a workspace is bound to localhost, i.e. accepts connections from local clients only. In this case, you need to restart the server with special flags/settings. Usually it boils down to replacing `localhost` with `0.0.0.0` or using special arguments with server start scripts.
