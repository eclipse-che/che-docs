---
tags: [ "eclipse" , "che" ]
title: Runtime Recipes
excerpt: ""
layout: docs
permalink: /:categories/runtime-recipes/
---
{% include base.html %}

A recipe defines part of the runtime of a workspace. A recipe is included in a [stack]({{base}}{{site.links["devops-runtime-stacks"]}}) along with meta information that defines how the workspace runtime should be created. When creating custom workspace runtime it's often best to create a custom [stack]({{base}}{{site.links["devops-runtime-stacks"]}}) with a custom recipe.

Workspaces can have a single runtime or multiple runtimes.  Che uses Docker, though Che could handle runtimes other than Docker, to create runtime(s) from [Dockerfiles](https://docs.docker.com/engine/reference/builder/) for a single-container runtime, or [compose files](https://docs.docker.com/compose/overview/) to create single-container/multi-container runtime(s).

Che provides recipes for all of the ["Ready-to-go" stacks]({{base}}{{site.links["devops-runtime-stacks"]}}#ready-to-go-stacks) for things like Java, PHP, Node, ASP.NET, and C++.

A recipe references either a Dockerfile or compose definition that need to be built into image(s) or reference already-built image(s). When a workspace is created from a particular stack, Che will take a recipe, create or use existing Docker image(s) from it, and then create runtime Docker container(s) from that/those image(s). That/Those runtime Docker container(s) will be your workspace runtime(s).

[Workspace agents]({{base}}{{site.links["devops-ws-agents"]}}) include the additional libraries that you may need, such as yum or npm, along with the runtime services that Che needs, such as Java and Tomcat, a SSH daemon. [Workspace agents]({{base}}{{site.links["devops-ws-agents"]}}) are then injected into runtime Docker container(s) from Docker images such as certified minimal versions of Linux operating systems like Alpine, Debian or Ubuntu with added [Che dependencies]({{base}}{{site.links["devops-runtime-recipes"]}}#che-runtime-required-dependencies).

# Single-Container Recipes  

## Defining
You can author your own recipe as a way to make your workspace runtime shareable. You can provide a URL to a custom recipe (Dockerfile or Docker compose file) or write a new custom recipe (Dockerfile or Docker compose file) from the dashboard.

Please note, Eclipse Che only [supports certain compose syntax]({{base}}{{site.links["devops-runtime-recipes"]}}#multi-container-recipes).

There are two ways for you to create a custom recipe that can be used within Che:

1. Inherit from an Eclipse Che base Docker image and then add your dependencies (easiest).
2. Inherit from a non-Eclipse Che base Docker image, then add both your dependencies, and Che's dependencies (most flexible).

### Inherit From an Eclipse Che Base Image
This is the easiest way to build a workspace from a custom recipe.  Eclipse Che base images are authored by Codenvy and hosted on DockerHub. These base images have all of the dependencies necessary for a Che workspace to operate normally. These base images may have unnecessary dependencies for your project, like subversion. So if size and performance are essential, you can look to author your own. The Dockerfiles for Che's base images are located in [Che GitHub repository](https://github.com/eclipse/che-dockerfiles/tree/master/recipes).

To reference Che Docker images in your Dockerfile or Docker compose recipe:

```shell  
##Dockerfile
FROM eclipse/<image-name>

##Compose
image: eclipse/<image-name>
```

Che base stacks, which include the minimum utilities for everything needed by Eclipse Che are `eclipse/stack-base:debian` and `eclipse/stack-base:ubuntu`. The majority of Che ready to go images are based on Ubuntu. All stacks have the right CMD, so that containers do not exit just after starting.

In `che-dockerfiles` repository, some recipes have sub-directories which represent tags. For example, the `/php/gae` directory in the GitHub repository would be pulled as `eclipse/php:gae` from Docker Hub.

### Inherit From Non-Eclipse Che Base Images
This will create the best performing workspace image by only installing the minimum dependencies and packages required for your workspace. The trade off is that you have to include [Che's runtime dependencies]({{base}}{{site.links["devops-runtimev-recipes"]}}#che-runtime-required-dependencies) so we can work our magic in the workspace.

### Che Runtime Required Dependencies

| Dependency   | Why?   | How? (Ubuntu/Debian)
| --- | --- | ---
| User with `root` privileges   | To install our developer tools agents (like terminal access and intellisense) we need root access or a user who has sudo rights.   | `USER root` <br/><br/> or grant your preferred user sudo rights without password prompt.
| Non-terminating CMD  | To keep a container running | Dockerfile <br/> `CMD tail -f /dev/null` <br/><br/> Compose <br/> `command: [tail, -f, /dev/null]`

All Eclipse Che images must have a non-terminating `CMD` command so that the container doesn't shut down immediately after loading. If you want to override the default `CMD`, add `tail -f /dev/null` to the execution.  For example:

```shell  
##Dockerfile
CMD sudo service apache2 start && tail -f /dev/null

##Compose
command: [sudo, service, apache2, start, &&, tail, -f, /dev/null]
```

### Maven Dependencies (Optional)
If you want to use Che with the maven plug-in, then you need to add these additional dependencies.

| Dependency   | Why?   | How?
| --- | --- | ---
| `mvn`   | Maven plugin needs Maven 3.3.9 or higher.   | `wget -qO- \http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-3.3.9-bin.tar.gz\ | tar -zx --strip-components=1 -C /home/user/apache-maven-3.3.9/`
| `M2_HOME` environment variable exported   | Maven plugin uses this variable to detect if Maven is installed.   | Dockerfile <br/> `ENV M2_HOME /home/user/apache-maven-3.3.9` <br/><br/> Compose <br/><br/> `environment:`<br/><br/> `- M2_HOME=/home/user/apache-maven-3.3.9`

### Other Optional Dependencies

| Dependency   | Why?   | How? (Ubuntu/Debian)
| --- | --- | ---
| `svn`  | Required to import projects stored in subversion repositories. | `sudo apt-get install subversion -y`

Even though Che workspaces require Java 1.8, it is ok not to have it in your custom image. In this case, Che agent will automatically install it. Of course, this takes time (openjdk package is installed via a package manager like apt-get, dnf or yum).


### Exposing Ports (Mandatory)

All workspace processes run in Docker containers. Che uses Docker's method to access/preview apps by [exposing and publishing ports](https://docs.docker.com/engine/reference/run/#expose-incoming-ports).

All ports exposed in a base image are randomly published by Docker onto host interfaces. Docker uses the [ephemeral port range](https://docs.docker.com/engine/userguide/networking/default_network/binding/) to externalize your services' ports. What Che does with exposed ports is an equivalent to `docker run -P` where `-P` lets Docker choose local ports.

To make your app/process accessible

**1: Expose the port your app/process is bound to**. For example, if your application runs on 3000, add the following instruction to your custom Dockerfile or  Docker compose recipe:

```shell  
##Exposing a single port in a Dockerfile
EXPOSE 3000

##Exposing a single port in a compose file
expose: 3000

##Exposing multiple ports in a Dockerfile
EXPOSE 3000 5000

##Exposing multiple ports in a compose file
expose:
 - 3000
 - 5000
```

**2: Go to user dashboard for your workspace** and click on the Runtimes tab. Select your machine and then in a section called "Server" you will see a table with all the ports exposed in the recipe and their corresponding externally published ports.

**3: You can also get the published port automatically by using a macro** in a [command]({{base}}{{site.links["ide-commands"]}}). When authoring a command, set its preview URL to `${server.port.<your-apps-port>}` where `<your-apps-port>` is the port in your recipe's expose command. When the command is executed, this macro is translated into a `host:port` URL.

There is no way to expose a port once the workspace is running. To expose an additional ports, the ports need to be added to the runtime recipe or added directly to the runtime instance via the dashboard `Workspaces>(click workspace name)>Runtime Tab`.

![che-workspace-runtime-servers.png]({{ base }}{{site.links["che-workspace-runtime-servers.png"]}})

## Issue a Pull Request To Improve Recipes
We really love pull requests. We are always looking to increase the set of stacks that are available for development. Please suggest a fix or add a new base image recipe.  To do so, issue [pull requests](https://github.com/codenvy/dockerfiles). If you add a new Dockerfile, it will be added as a source for a new automated build at DockerHub.  Please sign the [Eclipse contributor agreement](https://eclipse.org/legal/ECA.php) before making a contribution. Your contribution will be licensed as [EPL 1.0](https://www.eclipse.org/legal/epl-v10.html).

# Multi-Container Recipes  
The majority of the Docker Compose file syntax works with Eclipse Che. However, Che is a distributed system that supports multiple users on a single node, and in order to manage this distribution and multi-user capabilities, there are certain compose features that are not supported.

## Unsupported Compose Syntax

### Local "build.context" and "build.dockerfile"
Since Che workspaces can be distributed, you cannot have host-local build and Dockerfile contexts. You can, however, place these aspects so that they are remotely hosted in a git repository. Che will source the file from the remote system and then use it as its build context.

If the Dockerfile or build context requires other files to be `ADD` or `COPY` into the image that is created, then you could run into a failure, as the local Che workspace generator will not have access to those other remote files. To address this issue, you can pre-package the build context or Dockerfile into an image, push into a registry, and then reference the already-built image in your compose file. This is what we do for internal development at Codenvy.

```yaml  
build:
  ## remote context will work
  context: https://github.com/eclipse/che-dockerfiles.git#master:recipes/ubuntu_jre

  ## local context will not work
  context: ./my/local/filesystem
```

Using Private Repositories:
If your `build.context` or `build.Dockerfile` accesses a private remote registry, you need to provide additional configuration.  First, the SSH private key needs to be located in your host machine's home directory `~/.ssh/id_rsa` for Mac/Linux and `C:\Users\<username>\.ssh\id_rsa` for Windows with `0600` permissions for the user that starts Che.  Second, add the hostname of the private repository to the known hosts of the host machine using `ssh -o StrictHostKeyChecking=no -T git@<hostname>`.  Third, add the public key to the git [repository host]({{base}}{{site.links["ide-git-svn"]}}#adding-ssh-public-key-to-repository-account). Finally, you can use an SSH git URL in the `build.context` of your compose syntax.

```shell  
## On Linux/Mac host machine
## To new create ssh keypair
ssh-keygen

## Set permissions to private key file.
chmod 0600 ~/.ssh/id_rsa

## Add private repo host such as github to known_hosts file
ssh -o StrictHostKeyChecking=no -T git@github.com
```

```shell  
## On Windows host machine start bash
bash

## To new create ssh keypair
> ssh-keygen

## Set permissions to private key file
> chmod 0600 ~/.ssh/id_rsa

## Add private repo host such as github to known_hosts file
> ssh -o StrictHostKeyChecking=no -T git@github.com
> exit

## If using boot2docker(virtualbox) not HyperV
docker run -v /c/Users/%username%/.ssh:/mnt/.ssh -v /root/:/mnt/linRoot alpine sh -c "cp -r /mnt/.ssh /mnt/linRoot/ && chmod 0600 /mnt/linRoot/.ssh/id_rsa"
```

```yaml  
## The following will use master branch and build in recipes/ubuntu_jre folder
build:
  context: git@github.com:eclipse/che-dockerfiles.git#master:recipes/ubuntu_jre
```

### Build Image
In the event that a Compose file includes both build instructions and a build image the build instructions are seen as overriding, so the build image is skipped if it exists.

### Container Name

```yaml  
container_name: my_container
```

`container_name` is skipped during execution. Instead, Che generates container names based on its own internal patterns. Because many developers could be running the same Compose file on the same Che workspace node at the same time naming conflicts need to be avoided.

### Volumes
Volumes are not supported in the Che system. Instead we suggest using `volumes_from` to gain access to [volume mount]({{base}}{{site.links["devops-volume-mounts"]}}) of the `dev-machine`.

### Networks

```yaml  
## Not supported
networks:
  internal:
  aliases: ['my.alias’]
## Not supported
networks:
  internal:
  driver: bridge
```

Che does not yet currently support compose networks. We do, however, support the use of aliases through `links` command.

### Hostname
Hostname is not supported and the machine's name will be used for the hostname. User can use `links` aliases syntax to add additional hostname(s) to a machine.

### Ports
Binding ports to the host system is not supported. This is done to ensure that each container does not used already assigned host ports because many developers could be running the same compose file on the same Che server host at the same time. Users can expose ports and provide a [command macro]({{base}}{{site.links["ide-commands"]}}#macros) `${server.port.<port>}` in the IDE to determine the ephemeral port assigned.  

### Privileged
To secure the underlying host system `privileged` compose command is not supported.

The Che server can be configured to give all containers privileged access by setting the environment variable `CHE_PROPERTY_machine_docker_privilege__mode=true`. However, this makes the host system vulnerable and gives all containers access to the host system.

### Environment File
The `env_file` compose command is not supported. Environment variables can be manually entered in compose file or `source /<path>/<environment filename>` can be added to the `command` compose command.
