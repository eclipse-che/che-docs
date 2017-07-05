---
tags: [ "eclipse" , "che" ]
title: Assembly Dev Lifecycle
excerpt: "An assembly is a packaging of Che libraries, extensions, agents, and branding elements to create a new Che distribution."
layout: docs
permalink: /:categories/assembly-lifecycle/
---
{% include base.html %}

You can create new Che products for re-distribution by generating a custom assembly. An assembly is a binary packaging of IDE extensions (written in Java / JavaScript), Che extensions (deployed in the Che server), workspace extensions (deployed in a workspace agent), custom agents, stacks, templates, custom CLI, and brand elements. When these are packaged together, a complete binary that can be run identically to how you run the standard Che assembly is provided.

Everything can be customized allowing you to create any new kind of cloud IDE or workspace server.

# Development Lifecycle
Custom assemblies are git projects that are generated in the same structure of Che itself. Your custom assembly will inherit its libraries from Che and allow you locations to override default behaviors with your own.

The assembly development lifecycle:

1. Generate - We provide an `archetype` utility to generate new custom assemblies that already contain basic customizations.
2. Build - Use the `archetype` utility or `mvn clean install` to package the custom assembly for execution.
3. Run - The custom assembly is executed with the standard CLI by mounting it to `:/assembly`. The new binaries will be used instead of those that are distributed within the standard `eclipse/che-server` Docker image.
4. Customize - Add different types of custom extensions, agents, stacks, templates, and brand elements.
5. Debug - Debug your customizations for browser, Che, and workspace extensions running within a custom assembly.

# Archetype
The CLI has an `archetype` command that can be used to generate custom assemblies of Eclipse Che and Codenvy.

An archetype is a maven technique for generating code templates. A single archetype has an ID and generates a complete custom assembly. Different archetypes generate assemblies with different types of customizations. We make each archetype customize the minimal number of features to make learning about customizations simpler.

Your host system must have Maven 3.3+ installed to facilitate generation and compiling of custom assemblies. You must pass in your Maven's M2 repository path on your host. Our archetype generator will download libraries into that repository making repeated compilations faster over time. On most Linux based systems, your M2 repository is located at `/home/user/.m2/repository` and it is `%USERPROFILE%/.m2/repository` for Windows. We default your M2 repository to `/home/user/.m2/repository`. Use the `/m2` mount to change this.

The syntax is:

```shell
USAGE: DOCKER_PARAMS eclipse/che-cli:nightly archetype ACTION [PARAMETERS]

Use an archetype to generate, build or run a custom che assembly

MANDATORY DOCKER PARAMETERS:
  -v <path>:/archetype        Local path where your custom assembly will be generated

OPTIONAL DOCKER PARAMETERS:
  -v <path>:/m2               Local path to your hosts Maven M2 repository

ACTION:
  all                         Generate, build and run a new custom assembly
  generate                    Generate a new custom assembly to folder mounted to '/archetype'
  build                       Uses 'eclipse/che-dev' image to compile archetype in '/archetype'
  run                         Starts che from custom assembly in '/archetype'

PARAMETERS:
  --archid=<id>               Different archetypes generate different types of customizations
  --archversion=<version>     Sets archetype version - default = tag of CLI image
  --version=<version>         Sets custom assembly version - default = archetype version
  --group=<group>             Sets groupId of generated assembly - default = com.sample
  --id=<id>                   Sets artifactId of generated assembly - default = ID of archetype
  --no:interactive            Disables interactive mode
```

# Generate
The `generate` action will generate a new Maven multi-module project into the folder you mount to `/archetype`. Explaining the nature of the command is best served with an example. For example, on a Windows machine run:

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
  -v /c/Users/Tyler/.m2/repository:/m2
    eclipse/che-cli:5.14.0
      archetype generate
```

This will provide an interactive experience, downloading some utility images and giving you a list of archetypes to choose from. It will generate a new custom assembly from a template. It is essential that you have Maven installed locally on your host and that you mount your Maven's repository to `/m2`. This will allow the archetype Docker command to download various libraries and cache them into your local repository (to be used in the build phase).

You can skip interactive mode along with generate, build and run the new assembly in a single command:

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
  -v /c/Users/Tyler/.m2/repository:/m2
    eclipse/che-cli:5.14.0
      archetype all --no:interactive
```

This command:

#### Linux
On Linux, the Maven utility launched by the CLI may have problems writing files to your host system during the generation phase. To overcome this limitation create the host mount directories before launching docker, and in the `docker run ...` syntax before the image name add `--user={uid}` where UID is the user identity of your current users. This user identity will be passed into the various CLI utilities to execute under that user identity.

Example

```
      -v /etc/group:/etc/group:ro \
      -v /etc/passwd:/etc/passwd:ro \
      --user=1000:100  \
      --group-add 999 \
```

Therefore a full set of commands may look like this to do an interactive generate:

```
mkdir /tmp/archetype
mkdir /tmp/data
docker run -it --rm  \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/archetype:/archetype \
  -v /tmp/data:/data \
  -v ~/.m2/repository:/m2 \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  --user=1000:1000 \
  --group-add 999 \
    eclipse/che-cli:5.14.0 \
      archetype generate
```

To determine which user and group to use in the command type `id` in a bash shell - you'll get output similar to the following:

```
uid=1000(florent) gid=100(users) groups=100(users),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),108(netdev),999(docker)
```

For `--user` you need the ID of your user (1000 in the example above) and their group (100). For `--group-add` you need the ID of the group associated with `docker` (999).

#### Archetypes List
We provide different archetypes that will generate custom assemblies with different types of customizations. You can see the list of available archetypes by running the `archetype` command without `--no:interactive`. You will be prompted to choose from a list. These archetypes are provided as small sets of customization to simplify the learning experience for new developers with Che. For each of the archetypes that we provide, we also have a short section discussing the relevant elements modified to make the assembly work.

Each archetype has a unique artifactId, which you can specify on the command line with `--archid`. We also generate new versions of each archetype during each release of Che. You can choose a specific version of the archetype with the `--archversion` parameter.

The generator and templates for each assembly is in an [assembly generator repository](https://github.com/eclipse/che-archetypes/blob/master/README.md).

| Archetype ID | Assembly Contents |
| ------------ | ---------------- |
| `agent-archetype` | Sample custom agent |
| `plugin-menu-archetype` | IDE extension to customize the menu |
| `plugin-wizard-archetype` | Custom C project type extension |
| `plugin-serverservice-archetype` | Simple IDE extension and a workspace service |
| `plugin-embedjs-archetype` | IDE extension with JavaScript in widgets |
| `plugin-json-archetype` | JSON project type, codeassistant, and workspace service |
| `stacks-archetype` | An assembly with a custom stacks module |

#### Overrides
The custom assembly is generated as a Maven multi-module project. Maven scaffolds and expects a particular folder structure that separates source code, resources (like images), and test code into different folders. Maven uses a three-variable combination of artifactId, groupId, and version to uniquely identify a project. When we generate your custom assembly, default values for each of these are provided. You can override them on the command line with `--id`, `--group`, and `--version`.

# Build
You can build the assembly into a package using the Che CLI or with native maven utilities. The CLI is generally slower because file operations are performed over file mounts, however using native maven utilities requires your host system to be configured with a variety of additional libraries depending upon the modules you wish to build.

Given the example we started above, you compile it with:

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
  -v /c/Users/Tyler/.m2/repository:/m2
    eclipse/che-cli:5.14.0
      archetype build
```

#### CLI
If you use the CLI to compile the custom assembly, we use a Docker image named `eclipse/che-dev` to perform the build. It contains the utilities required to build a Che assembly and every sub-module. Each module, such as agents, dashboard, and IDE, have different dependencies, compilers, and unit test utilities. This image makes getting started really easy, but it's a monster, weighing in at >1GB!

With the CLI, run `archetype build` with the location of your already-generated assembly mounted to `/archetype`. If you use the `all` command, a build step will be invoked automatically by the CLI. The `archetype` action will configure a container from `eclipse/che-dev` and give it a `mvn clean install` command for the assembly.

You can bypass the CLI and use `eclipse/che-dev` directly. We maintain an explanation of the syntax for this image in the repository where this image's Dockerfile is located.  https://github.com/eclipse/che/blob/master/dockerfiles/dev/Dockerfile.

For example, given the sample we started with, the `eclipse/che-dev` equivalent would be:
```
docker run -it --rm --name build-che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /c/Users/Tyler/.m2/repository:/home/user/.m2/repository \
           -v /c/archetype/assembly:/home/user/che-build \
           -w /home/user/che-build \
              eclipse/che-dev mvn clean install
```
If this were a Linux system, there would be additional volume mounts required and you must set the user identity with `--user`.

Example:

```
docker run -it --rm  \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/archetype:/archetype \
  -v /tmp/data:/data \
  -v ~/:/home/$USER/ \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  --user=1000:1000 \
  --group-add 999 \
  -w /archetype/assembly \
    eclipse/che-dev \
      mvn clean install
```

To determine which user and group to use in the command type `id` in a bash shell - you'll get output similar to the following:

```
uid=1000(florent) gid=100(users) groups=100(users),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),108(netdev),999(docker)
```

For `--user` you need the ID of your user (1000 in the example above) and their group (100). For `--group-add` you need the ID of the group associated with `docker` (999).

The full syntax for this Docker image is [within the Che repository](https://github.com/eclipse/che/blob/master/dockerfiles/dev/Dockerfile).

#### Native
While the Docker approach to compiling an assembly is simple, it is slower. You can perform a native build with `mvn clean install` in the root of the assembly (the folder with the `pom.xml`) or any module that is a sub-folder within the assembly. If you have the right utilities installed, Maven will go about downloading necessary dependencies, perform compilation, execute unit tests, and give you a custom assembly. The custom assembly is placed into the `/target` sub-folder of the assembly that is built.

Compiling an assembly requires other tools like Java, Angular, Go to be installed on your host system. Each module of the assembly requires different dependencies. You can view the README.md in Che's source repository for the requirements to build that module. We also discuss many of the requirements and techniques for improving build performance [in the Che wiki](https://github.com/eclipse/che/wiki/Development-Workflow) where the internal development workflow is discussed.

#### Scripts
After you have generated a custom assembly, we provide a `build.sh` that will work for Windows, Mac and Linux within the root of each repository. You can run this script as an alternative to authoring the CLI syntax by hand.

# Run
A custom assembly is packaged into a set of binaries that can be used with the Che Docker image to launch Che servers. The finalized build is located in `assembly/assembly-main/target`.

You can run this custom assembly either by using the `archetype` command or with the Che CLI. The `archetype run` action will use your assembly details and launch the Che CLI automatically with the proper location of the custom assembly. Given the example we have started, this would look like (note that mounting the M2 repository is not required as we are not building with Maven):

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
    eclipse/che-cli:5.14.0
      archetype run
```

On Linux:

```
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/archetype:/archetype \
  -v /tmp/data:/data \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  --user=1000:1000 \
  --group-add 999 \
    eclipse/che-cli:5.14.0 \
      archetype run
```

Optionally, you can use the Che CLI to run a custom assembly by mounting `/assembly` to the exploded location of the assembly that has already been built. While developing Che and Codenvy itself, our engineers keep a branch open, work on customizations, and then build those customizations into an assembly that they mount with the CLI.

The exploded assembly is usually something like `assembly/assembly-main/target/eclipse-che-<version>/eclipse-che-<version>/`. You can use the rest of the CLI's options and parameters as you normally would. For example, given the sample we started with, the CLI direct launch equivalent would be:
```
docker run -it --rm --name run-che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /c/tmp:/data \
           -v /c/archetype/assembly/assembly-main/target/eclipse-che-5.14.0/eclipse-che-5.14.0:/assembly \
              eclipse/che:5.14.0 start --skip:nightly
```

On Linux:
```
docker run -it --rm --name run-che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /tmp/data:/data \
           -v /tmp/archetype/assembly/assembly-main/target/eclipse-che-5.14.0/eclipse-che-5.14.0:/assembly \
              eclipse/che:5.14.0 start --skip:nightly
```


Within the assembly itself is a `run.sh` script that works for Windows, Mac, and Linux to run the custom assembly using Docker. You can pass either `run.sh --che` or `run.sh --codenvy` to choose whether you are starting Che or Codenvy.

# Stop
You can stop a custom assembly with the CLI's `stop` command or with `archetype stop`:
```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
    eclipse/che-cli:5.14.0
      archetype stop
```

On Linux:

```
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/archetype:/archetype \
  -v /tmp/data:/data \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  --user=1000:1000 \
  --group-add 999 \
    eclipse/che-cli:5.14.0 \
      archetype stop
```

Within the assembly is a `stop.sh` script that works for Windows, Mac, and Linux to run the custom assembly using Docker. You can pass either `stop.sh --che` or `stop.sh --codenvy` to choose whether you are starting Che or Codenvy.

# Che vs. Codenvy
The `archetype generate` command will generate two custom assemblies: one for Eclipse Che and one for Codenvy, which is an enterprise adaptation of Che that adds multi-node scalability, a user database, and security controls. Eclipse Che extensions are deployable within a Codenvy custom assembly. There are some elements of configuration that are slightly different between the assemblies, so we provide both to provide comparison between the various packages.

The Eclipse Che and Codenvy CLI have (mostly) identical syntax, so you can build and run either custom assembly. By default, the `archetype build` and `archetype run` commands default to the Che custom assembly.  You can switch to the Codenvy assembly by appending `--codenvy` to either command.

# Customizing
Our archetypes generate a functional custom assembly with some pre-built customizations. You can further customize an assembly by:
- Excluding plugins or assets from Che / Codenvy
- Including new plugins or assets that you have created
- Both

For example, if you want to replace Che's git plugin with an improvement that you make, you would both exclude the default one provided by Che and then include a new plugin that you author.

After you exclude / include new plugins, perform another build to package the assembly with the updated plugin list.

#### Standard Assemblies
There are five different places where you can include or exclude a plugin, which are items we call "standard assemblies". The "standard assemblies" generate packages that will be run as an asset in a different location. Che and Codenvy are distributed systems, so there are components that run in a browser, on the server, and within a workspace. Each one of these components are independently packaged into a "standard assembly".

| Che Assembly Location | What Is Included |
| --------------------- | ---------------- |
| `/assembly-che/assembly-ide-war` | GWT plugins that will be compiled into a new browser IDE as JavaScript |
| `/assembly-che/wsagent-war` | Java plugins that will run within a workspace's agent |
| `/assembly-che/wsagent-server` | Packages workspace agents into a Tomcat bundle |
| `/assembly-che/wsmaster-war` | Java plugins that will run within Che's core server |
| `/assembly-che/assembly-main` | Packages Che's core server into a Tomcat bundle |

And Codenvy's assemblies are slightly different:

| Codenvy Assembly Location | What Is Included |
| ------------------------- | ---------------- |
| `/assembly-codenvy/compiling-ide-war` | GWT plugins that will be compiled into a new browser IDE as JavaScript |
| `/assembly-codenvy/assembly-ide-war` | Results of GWT plugins packaged into a new web app |
| `/assembly-codenvy/assembly-dashboard-war` | JavaScript plugins that will be packaged into the user dashboard |
| `/assembly-codenvy/assembly-factory-war` | Plugins for workspace automation with factories |
| `/assembly-codenvy/wsagent-war` | Java plugins that will run within a workspace's agent |
| `/assembly-codenvy/wsagent-server` | Packages workspace agents into a Tomcat bundle |
| `/assembly-codenvy/wsmaster-war` | Java plugins that will run within Che's core server |
| `/assembly-codenvy/assembly-main` | Packages Che's core server into a Tomcat bundle |


#### Exclude
You can exclude existing Che or Codenvy plugins from your custom assembly.

In the appropriate assembly where you want to remove a plugin, such as `assembly-che/assembly-ide-war/pom.xml`, add an `<exclusions>` code block to the maven definition. You can provide an exclusion for each plugin provided by Che individually:

```
<dependency>
  <groupId>org.eclipse.che</groupId>
  <artifactId>assembly-ide-war</artifactId>
  <classifier>classes</classifier>
  <exclusions>
    <exclusion>
      <groupId>org.eclipse.che.plugin</groupId>
      <artifactId>PLUGIN-IDENTIFIER</artifactId>
    </exclusion>
  </exclusions>
</dependency>
```

You can do a similar activity for the Codenvy custom assembly as well located in `assembly-codenvy/assembly-ide-war/pom.xml`:

```
<dependency>
  <groupId>com.codenvy.onpremises</groupId>
  <artifactId>compiling-ide-war</artifactId>
  <classifier>classes</classifier>
  <exclusions>
    <exclusion>
      <groupId>com.codenvy.plugin</groupId>
      <artifactId>PLUGIN-IDENTIFIER</artifactId>
    </exclusion>
  </exclusions>
</dependency>
```

The `PLUGIN-IDENTIFIER` is the `artifactId` that is provided by the plugin. You can find this identifier in the `pom.xml` that is in the root folder for each plugin in Che and Codenvy's source repository.

You can have as many `<exclusion>` blocks as necessary within a single `<exclusions>` tag.

We require the maven POM to be sorted. If you get a sorting error, you can sort your modifications on the command line with `mvn sortpom:sort`.

#### Include
You include your plugin by modifying the same assembly `pom.xml` and add a new `<dependency>` block:
```
<dependency>
  <groupId>YOUR-PLUGIN-GROUP-IDENTIFIER</groupId>
  <artifactId>YOUR-PLUGIN-IDENTIFIER</artifactId>
</dependency>
```

We require the maven POM to be sorted. If you get a sorting error, you can sort your modifications on the command line with `mvn sortpom:sort`.

# IDE
You can use your own IDE for developing plugins that are deployed within Che. We use Eclipse, Che and IntelliJ internally to create Che itself. You can [create a similar development environment and workflow](https://github.com/eclipse/che/wiki/Development-Workflow#ide-setup) for customizations that you make.

# Debugging
It's a custom assembly, so this means you are either changing our custom plugins or adding your own as new code. Most customizations are either an IDE extension, a server extension, or a workspace extension. You can set up a debugger for tracking your code in each of these different extensions:

1. [Debug IDE extensions](https://github.com/eclipse/che/wiki/Development-Workflow#debugging-che-ide-extensions)
2. [Debug Che extensions](https://github.com/eclipse/che/wiki/Development-Workflow#debugging-che-server)
3. [Debug workspace and agent extensions](https://github.com/eclipse/che/wiki/Development-Workflow#debugging-workspace-agent)

# Versioning
Your custom assembly inherits from a base platform from Eclipse Che or Codenvy. When you first generate a custom assembly, you select the version of Che / Codenvy that you have as a base platform. You can have your customer assembly use a new version by modifying two files and then rebuilding the assembly.

1. In your assembly's primary `pom.xml`, change the version in the `<parent>` tag to the new version of Che or Codenvy you want to use as a base.

```xml
<parent>
  <artifactId>maven-depmgt-pom</artifactId>
  <groupId>org.eclipse.che.depmgt</groupId>
  <version>5.5.0-SNAPSHOT</version>
</parent>
```

2. In the same file, update the properties fields with the new version.

```xml
<properties>
  <che.version>5.5.0-SNAPSHOT</che.version>
  <codenvy.version>5.5.0-SNAPSHOT</codenvy.version>
</properties>
```

You can then rebuild your assembly normally. The parent reference will trigger Maven to download the new dependency libraries that relate to that particular version.

# Creating Assemblies

There are two ways to build an assembly
1. As a minimal framework into which you can add plugins.
2. As a standard assembly with all included default plugins.

{% if site.product_mini_cli=="che" %}

There are two maven modules that you will need to consider:
- ```che-ide-core```: The core components of the IDE.
- ```che-wsagent-core```: The core components of the server-side workspace agent.

These two modules will be used to create either a standard assembly or a sample.

## Standard IDE Assembly
To make a standard assembly of the IDE, we need to declare it in `assembly/assembly-ide-war/pom.xml`.

**1) Standard IDE core only**

```
   <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-ide-core</artifactId>
   </dependency>
```

**2) Standard IDE core plus all Che IDE plugins**

```
   <dependency>
      <groupId>org.eclipse.che.plugin</groupId>
      <artifactId>*</artifactId>
   </dependency>
```

## Minimal IDE Assembly
To make a minimal assembly of the IDE, we need to declare it in `assembly/assembly-ide-war/pom.xml`.

**1) Minimal IDE core only**

```
   <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-ide-core</artifactId>
   </dependency>
```

**2) Minimal IDE core plus all Che IDE plugins**

```
   <dependency>
      <groupId>my.plugin</groupId>
      <artifactId>plugin-json-ide</artifactId>
   </dependency>
```

**3) Minimal IDE WAR that will be reused to get some resources**

```
   <dependency>
      <groupId>org.eclipse.che</groupId>
      <artifactId>assembly-ide-war</artifactId>
      <type>war</type>
      <scope>runtime</scope>
   </dependency>
```

## Standard Assembly of ws-agent Server WAR

**1) Core ws-agent WAR**

```
   <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-wsagent-core</artifactId>
      <type>war</type>
   </dependency>
```

**2) Swagger support**

```
   <dependency>
      <groupId>org.eclipse.che.lib</groupId>
      <artifactId>che-swagger-module</artifactId>
   </dependency>
```

**3) All ws-agent plugins**

```
   <dependency>
      <groupId>org.eclipse.che.plugin</groupId>
      <artifactId>che-plugin-*</artifactId>
   </dependency>
```

## Custom Assembly of Minimal Che ws-agent

**1) Core ws-agent war**

```
    <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-wsagent-core</artifactId>
      <type>war</type>
   </dependency>
```

**2) Server side plugins**

```
   <dependency>
      <groupId>my.plugin</groupId>
      <artifactId>plugin-json-server</artifactId>
   </dependency>
```

{% endif %}

{% if site.product_mini_cli=="codenvy" %}

There are two maven modules that you will need to consider:
- ```codenvy-ide-core```: The core components of the IDE.
- ```codenvy-wsagent-core```: The core components of the server-side workspace agent.

These two modules will be used to create either a standard assembly or a sample.

## Standard IDE Assembly
To make a standard assembly of the IDE, we need to declare it in `assembly/compiling-ide-war/pom.xml`.

**1) Standard IDE core only**

```
   <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-ide-core</artifactId>
   </dependency>
```

**2)  All IDE plugins we have in Codenvy**

```
   <dependency>
      <groupId>com.codenvy.plugin</groupId>
      <artifactId>codenvy-plugin-*</artifactId>
   </dependency>
```

**3) All IDE plugins we have in Che**

```
   <dependency>
      <groupId>org.eclipse.che</groupId>
      <artifactId>assembly-ide-war</artifactId>
      <classifier>classes</classifier>
      <exclusions>
         <exclusion>
            <artifactId>che-plugin-product-info</artifactId>
            <groupId>org.eclipse.che.plugin</groupId>
         </exclusion>
      </exclusions>
   </dependency>
```

## Minimal IDE Assembly
To make a minimal assembly of the IDE, we need to declare it in `assembly/assembly-ide-war/pom.xml`.

**1) Codenvy IDE Core**

```
   <dependency>
      <groupId>com.codenvy.onpremises</groupId>
      <artifactId>codenvy-ide-core</artifactId>
      <scope>provided</scope>
   </dependency>
```

**2) IDE Part of a Custom Plugin**

```
   <dependency>
      <groupId>my.plugin</groupId>
      <artifactId>plugin-json-ide</artifactId>
      <scope>provided</scope>
   </dependency>
```

**3) IDE WAR is Reused to Get Key Resources**

```
   <dependency>
      <groupId>com.codenvy.onpremises</groupId>
      <artifactId>assembly-ide-war</artifactId>
      <type>war</type>
      <scope>runtime</scope>
   </dependency>
```

## Standard Assembly of ws-agent Server WAR

**1) Core ws-agent WAR**

```
   <dependency>
      <groupId>com.codenvy.onpremises.wsagent</groupId>
      <artifactId>codenvy-wsagent-core</artifactId>
      <type>war</type>
   </dependency>
```

**2) Swagger support**

```
   <dependency>
      <groupId>org.eclipse.che.lib</groupId>
      <artifactId>che-swagger-module</artifactId>
   </dependency>
```

**3) All Codenvy ws-agent plugins**

```
   <dependency>
      <groupId>com.codenvy.plugin</groupId>
      <artifactId>codenvy-plugin-*</artifactId>
   </dependency>
```

**4) All Che ws-agent plugins**

```
   <dependency>
      <groupId>org.eclipse.che</groupId>
      <artifactId>assembly-wsagent-war</artifactId>
      <classifier>classes</classifier>
      <exclusions>
         <exclusion>
            <artifactId>che-wsagent-core</artifactId>
            <groupId>org.eclipse.che.core</groupId>
         </exclusion>
      </exclusions>
   </dependency>
```

## Custom Assembly of Minimal Codenvy ws-agent

**1) Core Ws Agent WAR**

```
   <dependency>
      <groupId>com.codenvy.onpremises.wsagent</groupId>
      <artifactId>codenvy-wsagent-core</artifactId>
      <type>war</type>
   </dependency>
```

**2) Server Side Plugin**

```
   <dependency>
      <groupId>my.plugin</groupId>
      <artifactId>plugin-json-server</artifactId>
   </dependency>
```

{% endif %}

# Production Mode

If you want to deploy your custom Che binaries in a production mode, i.e. make them reusable and independent from a locally mounted repo, you may build your own custom Che CLI. Building a custom CLI also makes it possible to setup CI systems that will generate nightly and tagged images.

1. In the root of your custom Che assembly repo, create a directory `dockerfiles`
2. Copy all files and directories as in this [example](https://github.com/codenvy/plugin-openshift/tree/master/dockerfiles)
4. In [build.include](https://github.com/codenvy/plugin-openshift/blob/master/dockerfiles/build.include) change values of the following properties:
```
ORGANIZATION="yourOrg"
PREFIX="yourCustomAssembly"
```
Usually, `ORGANIZATION` is your DockerHub/container registry account. `PREFIX` is used in image names. With the above properties you will have:

* `yourOrg/yourCustomAssembly-server` server image
* `yourOrg/yourCustomAssembly-cli` cli image
* `yourOrg/yourCustomAssembly-init` init image with the default configuration


All Dockerfiles inherit base Che images. You should make sure that che-parent version in your root `pom.xml` is identical to the tag in `FROM` instruction in all 3 Dockerfiles (server, cli and init). If you stay with Che master, then nightly tags are OK. If you depend on a tagged Che version, use the same tag in a Dockerfile:

`FROM eclipse/che-server:nightly`

or

`FROM eclipse/che-server:5.10.0`


5. In `dockerfiles/cli/version/$TAG/images` make sure that your custom images are used. There is no need to change `IMAGE_COMPOSE`, just server and init images:

```
IMAGE_INIT=yourOrg/yourCustomAssembly-init:0.1.0
IMAGE_CHE=yourOrg/yourCustomAssembly-server:0.1.0
IMAGE_COMPOSE=docker/compose:1.8.1
```

When building tagged images with `build.sh` make sure you use an existing version otherwise CLI won't be able to find it. It is reasonable to always have `nightly`, 'latest' tagged tagged with the latest version and all tagged versions as well:

```
/0.1.0
/latest
/nightly
latest.ver
```

`latest.ver` file should also contain the latest version which makes it convenient to tag images in CI systems. This makes it possible to run images without tags, so that Docker automatically pulls the latest tag. `latest.ver` is optional though.

6. Run `build.sh` in all 3 subdirs in `dockerfiles` directory. By default all images will be tagged as `nightly`. You may specify tag with `--tag=$TAG` argument passed to a script.

7. Run your custom Che:

```
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v ~/che-data:/data yourOrg/yourCustomAssembly-cli:nightly start
```

You may run the latest (no tag) or a particular tag too:

```
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v ~/che-data:/data yourOrg/yourCustomAssembly-cli:0.1.0 start
```

Once `dockerfiles` directory is a part of your custom Che assembly repo, you may set up CI jobs to regularly build and push nightly and tagged images.

8. Optional. Custom Che configuration. If your assembly needs custom config (default configuration comes with the `init` image), you need to work with addons. See example for [OpenShift plugin](https://github.com/codenvy/plugin-openshift/tree/master/dockerfiles/init/addon)

Just mimic structure and approach, remove unnecessary properties and add your custom ones. If your assembly does not use custom properties, you do not need a custom init image at all, and may use `eclipse/che-init:$TAG` in `dockerfiles/build.include`


# Example
Let's walk through the folder structure for the custom assembly generated by the archetype identified by `plugin-wizard-archetype`. This is a custom assembly that has a server-side and IDE plugin that work with one another.

```shell
pom.xml
# Describes dependencies that are used throughout the custom assembly.
# Disables license and sortpom plugin executions defined in the parent POM.

assembly-che/assembly-ide-war
# Repackages the IDE by declaring dependencies from the source Che assembly along with
# including a new custom plugin and its associated shared model.
# Contains instructions for generating a master IDE GWT XML from dependencies.
# Contains GWT plugin for compiling into different browser types (permutations).
# Contains antrun task for attaching build information.
# Contains the WAR plugin configuration for adding resources (like icons) from the parent.

assembly-che/assembly-main
# Packages Che's server Tomcat which includes the `assembly-ide-war`.

assembly-che/assembly-wsagent-server
# Packages the workspace agent's Tomcat server, which includes `assembly-wsagent-war`.

assembly-che/assembly-wsagent-war
# Packages the server service into a Web app to be deployed within the workspace.

assembly-codenvy
# Same modules as Che, but configured for a Codenvy deployment

plugins/<artifactid>/<artifactid>-ide
# IDE extension written in Java & GWT

plugins/<artifactid>/<artifactid>-server
# REST extension to run within a workspace

plugins/<artifactid>/<artifactid>-shared
# Code that is shared between IDE and server (will be packaged in both)

build.include
# Utility funcations used by other scripts to define Docker and OS parameters

build.sh
# Compile a custom assembly into a package using Docker

run.sh
# Run a packaged custom assembly using the CLI

stop.sh
# Stop a running custom assembly
```

And because it is interesting, here is the file composition of the three plugins.

`plugins/<artifactid>/<artifactid>-shared`:
```shell
pom.xml
# Basic module descriptor

src/main/java/com/sample/shared/Constants.java
# Constants that are used across both IDE and server modules
```

`plugins/<artifactid>/<artifactid>-server`:
```shell
pom.xml
# Basic module descriptor

src/main/java/com/sample/inject/SampleWizardModule.java
# Dependency injection module, where binding of project type occurs

src/main/java/com/sample/projecttype/SampleProjectType.java
# Project type definition
```

`plugins/<artifactid>/<artifactid>-ide`:
```shell
pom.xml
# Basic module descriptor

src/main/java/com/sample/ide/SampleWizardExtension.java
# Extension definiton responsible for registering actions, menus, registrars, etc.

src/main/java/com/sample/ide/SampleWizardLocalizationConstant.java
# Interface for accessing GWT Localization constants written in .properties file

src/main/java/com/sample/ide/SampleWizardResources.java
# Interface for accessing GWT resources, like SVG icons

### The action package contains Actions to be triggered by buttons, menus, etc:
src/main/java/com/sample/ide/action/NewXFileAction.java
# Action which in this example will be triggered by menu selection

### The file package contains classes related to the "New X File" form:
src/main/java/com/sample/ide/file/NewXFilePresenter.java
# Presenter class, responsible for logic of file creation

src/main/java/com/sample/ide/file/NewXFileView.java
# View interface class, which is used in the presenter

src/main/java/com/sample/ide/file/NewXFileViewImpl.java
# View implementation class, containing GWT or JavaScript code to display the form

src/main/java/com/sample/ide/file/NewXFileView.ui.xml
# UIBinder XML file, A GWT concept to provide declarative layout of the "New X File" form

### The inject package contains GIN dependency injection module:
src/main/java/com/sample/ide/inject/SampleWizardGinModule.java
# Dependency injection GIN module, which binds constructors to your classes

### The wizard package contains a custom Project Wizard page:
src/main/java/com/sample/ide/wizard/SamplePagePresenter.java
# Presenter class, responsible for logic of Project Wizard custom project creation page

src/main/java/com/sample/ide/wizard/SamplePageView.java
# View interface class, which is used in the presenter

src/main/java/com/sample/ide/wizard/SamplePageViewImpl.java
# View implementation class, which contains GWT code for the Project Wizard creation page

src/main/java/com/sample/ide/wizard/SamplePageViewImpl.ui.xml
# A UIBinder XML file, which is a GWT declarative layout of the Project Wizard creation page

src/main/java/com/sample/ide/wizard/SampleWizardRegistrar.java
# Class that registers our custom page in the Project Wizard


### Resources define the plugin's GWT module, files like icons, and properties
src/main/resouces/com/sample/SampleWizard.gwt.xml
# GWT XML module snippet - will be included into a global GWT module created during build

src/main/resouces/com/sample/ide/SampleWizardLocalizationConstant.properties
# Properties of string constants, which  are used in GWT code for form names and so on

src/main/resouces/com/sample/ide/svg/c_file.svg
# SVG icon for custom project type displayed in the project wizard form

src/main/resouceseclipse/che-cli/ide/svg/category.svg
# SVG icon for custom project type category display in the project wizard form
```
