---
tags: [ "eclipse" , "che" ]
title: Custom Assemblies
excerpt: "An assembly is a packaging of Che libraries, extensions, agents, and branding elements to create a new Che distribution."
layout: docs
permalink: /:categories/assemblies/
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

# Generate
The CLI has an `archetype` command that can be used to generate custom assemblies of Eclipse Che and Codenvy.

An archetype is a maven technique for generating code templates. A single archetype has an ID and generates a complete custom assembly. Differnent archetypes generate assemblies with different types of customizations. We make each archetype customize the minimal number of features to make learning about customizations simpler.

Your host system must have Maven 3.3+ installed to facilitate generation and compiling of custom assemblies. You must pass in your Maven's M2 repository path on your host. Our archetype generator will download libraries into that repository making repeated compilations faster over time. On most Linux based systems, your M2 repository is located at `/home/user/.m2/repository` and it is `%USERPROFILE%/.m2/repository` for Windows. We default your M2 repository to `/home/user/.m2/repository`. Use the `/m2` mount to chnage this.

The syntax is:
```
USAGE: DOCKER_PARAMS eclipse/che-cli:nightly archetype ACTION [PARAMETERS]

Use an archetype to generate, build or run a custom che assembly

MANDATORY DOCKER PARAMETERS:
  -v <path>:/archetype        Local path where your custom assembly will be generated

OPTIONAL DOCKER PARAMETERS:
  -v <path>:/m2               Local path to your host's Maven M2 repository

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
  --id=<id>                   Sets artifaceId of generated assembly - default = assembly
  --no:interactive            Disables interactive mode
```

The `generate` action will generate a new Maven multi-module project into the folder you mount to `/archetype`. Explaining the nature of the command is best served with an example. For example, on a Windows machine run:
```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock 
  -v /c/archetype:/archetype 
  -v /c/tmp:/data 
  -v /c/Users/Tyler/.m2/repository:/m2 
    eclipse/che-cli:5.4.0 
      archetype all --no:interactive
```
This command:
1. Generate a custom assembly into the `C:\archetype` folder.
2. The archetype uses defaults without prompting the user (chooses the default IDE archetype).
3. During generation, the custom assembly's Maven dependencies will be saved to the host's maven repository at `C:\Users\Tyler\.m2\repository`.
4. The `all` command will trigger the `archetype` utility to also build and run the custom assembly.

#### Linux
On Linux, the Maven utility launched by the CLI may have problems writing files to your host system during the generation phase. To overcome this limitation, in the `docker run ...` syntax add `--user={uid}` before the image name where `uid` is the user identity of your current users. This user identity will be passed into the various CLI utilities to execute under that user identity.

#### Archetypes List
We provide different archetypes that will generate custom assemblies with different types of customizations. You can see the list of available archetypes by running the `archetype` command without `--no:interactive`. You will be prompted to choose from a list. These archetypes are provided as small sets of customization to simplify the learning experience for new developers with Che. For each of the archetypes that we provide, we also have a short section discussing the relevant elements modified to make the assembly work.

Each archetype has a unique artifactId, which you can specify on the command line with `--archid`. We also generate new versions of each archetype during each release of Che. You can choose a specific version of the archetype with the `--archversion` parameter.

#### Overrides
The custom assembly is generated as a Maven multi-module project. Maven scaffolds and expects a particular folder structure that separates source code, resources (like images), and test code into different folders. Maven uses a three-variable combination of artifactId, groupId, and version to uniquely identify a project. When we generate your custom assembly, default values for each of these are provided. You can override them on the command line with `--id`, `--group`, and `--version`.

# Build
You can build the assembly into a package using the Che CLI or with native maven utilities. The CLI is generally slower because file operations are performed over file mounts, however using native maven utilities requires your host system to be configured with a variety of additional libraries depending upon the modules you wish to build.

#### CLI
We maintain a Docker image named `eclipse/che-dev` which has all of the utilities included to build a Che assembly and every sub-library. Each sub-library like agents, dashboard, and IDE extensions have different dependencies, compilers, and unit test utilities. The development image is a dream for getting started, but it's a monster, weighing in at >1GB!

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

#### Native
You can run `mvn clean install` in the root of the assembly (the folder with the `pom.xml`) or any module that is a sub-folder within the assembly. If you have the right utilities installed, Maven will go about downloading necessary dependencies, perform compilation, execute unit tests, and give you a custom assembly. The custom assembly is placed into the `/target` sub-folder of the assembly that is built. 

Compiling an assembly requires other tools like Java, Angular, Go to be installed on your host system. Each module of the assembly requires different dependencies. You can view the README.md in Che's source repository for the requirements to build that module. We also discuss many of the requirements and techniques for improving build performance in the Che wiki where the internal development workflow is discussed.

# Run
A custom assembly is packaged as a set of archives (binaries) that can be used within a Che image to launch Che servers. The finalized build is located in `assembly/assembly-main/target`. 

You can run this custom assembly either by using the `archetype` command or with the Che CLI. The `archetype run` action will use your assembly details and launch the Che CLI automatically with the proper location of the custom assembly.

The Che CLI has an optional `/assembly` mount that you can use which is the location of an exploded  built assembly. The exploded assembly is usually something like `assembly/assembly-main/target/eclipse-che-<version>/eclipse-che-<version>/`. You can use the rest of the CLI's options and parameters as you normally would.

For example, given the sample we started with, the CLI direct launch equivalent would be:
```
docker run -it --rm --name run-che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /c/tmp:/data \
           -v /c/archetype/assembly/assembly-main/target/eclipse-che-5.4.0/eclipse-che-5.4.0:/assembly \
              eclipse/che:5.4.0 start --skip:nightly"
```




















# Che Layout  
A Che assembly has the following directory structure after it is installed.

```text  
/bin             # Scripts to start, stop, and manage Che
/conf            # Configuration files
/lib             # Workspace agent, terminal and other resources a workspace may require
/plugins         # Staging for Che plugins that you author
/sdk             # Che packaging with SDK tools required to compile custom Che assemblies
/templates       # Project samples that appear in dashboard or IDE
/tomcat          # App server used as a runner for Che extensions, packaged with war and jar artifacts
```

# Modules  
The purpose of the `http://github.com/eclipse/che/assembly` module is to generate Che assemblies. It has five sub-modules.

```text  
assembly-main            # Contains the base structure of a Che assembly
assembly-ide-war         # Generates the IDE web app (ide.war) loaded by Che server (client side)
assembly-wsagent-server  # Contains the base structure of a workspaces server
assembly-wsagent-war     # Generates a machine web app (ide.war) used by workspace agent (server side APIs)
assembly-wsmaster-war    # Generates IDE web app with server side components
```

Run `mvn clean install` in the `/assembly` module to build the project and generate an assembly.  The output of the `mvn clean install` command generates a new assembly and places the resulting files in the `target` folder. The `assembly-ide-war` module is the longest operation as it uses a GWT compilation operation to generate cross-browser JavaScript from numerous Java libraries. You can speed the assembly generation process by building `assembly-main`, which will download the latest IDE web application from Che's nexus repositories.

```text  
/assembly-main
  /target
    /archive-tmp
    /eclipse-che-{version}               # Exploded tree of assembly
    /dependency                          # Copied into /lib folder of assembly
    /dependency-maven-plugin-markers
    /findbugs
    eclipse-che-{version}.tar.gz         # TAR file of assembly
    eclipse-che-{version}.zip            # ZIP file of assembly
```

# Custom Assemblies  
You can generate assemblies that include custom plug-ins and [extensions]({{ base }}/docs/plugins/create-and-build-extensions/index.html). Custom assemblies can be distributed as ZIP or TGZ packages.

```shell  
che-install-plugin [OPTIONS]         
     -a            --assembly          Creates new distributable Che assembly with your plugins
     -s:deps,      --skip:deps         Skips automatic injection of POM dependencies of your plugins
     -s:maven,     --skip:maven        Skips running maven to inject your plugins into local repository
     -s:update,    --skip:update       Skips updating this assembly; leaves packages in /temp build dir
     -s:wsagent,   --skip:wsagent      Skips creating new ws agent
     -s:wsmaster,  --skip:wsmaster     Skips creating new ws master, which contains IDE & ws manager
     -d,           --debug             Additional verbose logging for this program
     -h,           --help              This help message
```

This utility will create new web application packages with your custom plugins and optionally create new assemblies. Custom plug-ins are placed into the /plugins directory. Che packages extensions and plug-ins into Web application packages that are then deployed by Che. The location of your plug-ins determines how your plug-ins will be packaged and deployed.

Place plug-in JARs & ZIPs:

| PlugIn Location   | What Is Built   
| --- | ---
| `/plugins/ide`   | IDE extension, compiled with GWT & packaged into new ws-master Web application.   
| `/plugins/ws-master`   | Server-side extension & packaged into new ws-master Web application with IDE.   
| `/plugins/ws-agent`   | Server-side extension that runs in workspace machine & packaged into new ws-agent Web application.   
| `/`   | Packaged in both ws-master and ws-agent Web applications. (Not Recommended)   

You extension is compiled into one of two Web applications:
1. Workspace Master.
2. Workspace Agent.

The workspace master is deployed into the core Che server. The workspace agent is deployed into the machine powering each workspace created by your users. Each workspace agent is unique to the workspace that created it. While you can deploy plug-ins into both locations, this is costly at compile and runtime.

The Che assembly is generated by Che utility in stages.

```text  
1. Install your plug-ins to a local maven repository.

2. Create a staging module to build new Web applications
   `/sdk/assembly-ide-war/temp`     --> Where ws-master web app will be generated
   `/sdk/assembly-machine-war/temp` --> Where ws-agent web app will generated

3. Your plug-ins are added as dependencies to the maven pom.xml in each staging module.

4. The new Web application packages are compiled and packaged in the staging directory.
    `mvn sortpom:sort`
    `mvn -Denforcer.skip=true clean package install -Dskip-validate-sources=true`

5. If your plug-ins are added into a workspace agent Web app, we then create a new ws-agent.zip.
   `/sdk/assembly-machine-server`          --> Packages ws agent Web app w/ Tomcat into ws-agent.zip.
   `mvn -Denforcer.skip=true clean package install`

6. The new Web applications are copied into your core Che assembly, overwriting old version.
   `/sdk/assembly-ide-war/temp/target/*.war`          --> /tomcat/webapps
   `/sdk/assembly-machine-server/target/*.zip`        --> /lib/ws-agent.zip
   Use `--skip:update` to avoid overwriting existing files.

7. If `--assembly`, then we create a new distributable package of Che.
   `/sdk/assembly-main`
   `mvn clean package`
```

# Runtime Deployment  
When Che is running, the embedded assets are deployed into different locations.

```text  
BROWSER CLIENT                           CHE SERVER                                 WORKSPACE (DOCKER)

                                         launches ws-agent.zip in workspace ----->  /webapps/ide.war
                                         launches terminal in workspace     ----->  /webapps/terminal

JS / CSS / HTML -- download from ---->   /tomcat/webapps/ide.war
JS / CSS / HTML -- download from ---->   /tomcat/webapps/dashboard.war

JS / CSS / HTML -- download from ------------------------------------------------>  /webapps/ide.war
JS / CSS / HTML -- download from ------------------------------------------------>  /webapps/terminal
```
Your browser clients download JavaScript, HTML, and CSS resources from two different locations, both from the Che server and from a second Che server that is running within the workspace. Each workspace has its own `ws-agent.zip` that is injected into the workspace at runtime by Che. The `ws-agent.zip` contains a second application server that is booted when the workspace is activated.

While both the Che server and the `ws-agent.zip` each have an `ide.war` web application within them, they are not identical. There are numerous common libraries between the two, but the Che server hosts the primary IDE files that are shared by clients across all workspace development, and the `ws-agent.zip` deployment contains additional libraries for plug-ins that perform workspace modification (such as doing local JDT intellisense) along with additional Che classes that make it possible for the workspace agent to communicate over REST to the Che server.

The `dashboard.war` web application is an Angular JS application that provides the user dashboard that is booted when Che launches. It is used for managing workspaces, projects and user preferences.

# Assembly Dependency Hierarchy  
There are two servers that are deployed when Che is started:
1. The Che server, and:
2. The workspace agent, which is a server running in each workspace

The Che assembly, packaged as `eclipse-che-{version}.zip` contains both servers. The following charts layout which assembly modules build each of the assets.

```text  
eclipse-che-{version}.zip                              ==> Generated by assembly-main
-> ide.war           ==> Placed in /tomcat/webapps     ==> Generated by assembly-ide-war
-> dashboard.war     ==> Placed in /tomcat/webapps     ==> Generated by che-dashboard repo
-> wsmaster.war      ==> Placed in /tomcat/webapps     ==> Generated by assembly-wsmaster-war
-> ws-agent.zip      ==> Placed in /lib                ==> Generated by assembly-machine-server
-> terminal          ==> Placed in /lib                ==> Generated by che-websocket-terminal repo
```

```text  
ws-agent.zip                                           ==> Generated by assembly-wsagent-server
-> tomcat            ==> Placed in /                   ==> Downloaded from Che maven repo
-> ide.war           ==> Placed in /webapps            ==> Generated by assembly-wsagent-war
   -> che-core-*.jar                                   ==> Downloaded from Che maven repo
   -> che-plugins-*.jar                                ==> Downloaded from Che maven repo
   -> ws-agent specialized classes                     ==> Built by assembly-machine-war
```
Note that the `ide.war` web application generated for the workspace agent is not identical to the one generated for the Che application server, even though they have the same name. The workspace agent does not include many of the IDE libraries and adds in additional libraries for communicating to the Che server and running plug-ins within the workspace itself.


# Che Repositories  
The `ide.war`, `ws-agent.zip`, and other assembly files depend upon a wide range of libraries. Many of these resources and libraries are stored in other Che repositories.

These are the repositories that are stored at `http://github.com/eclipse` organization. Each repository is referenced by its first entry, ie: `http://github.com/eclipse/che` or `http://github.com/eclipse/che-dependencies`.

```shell  
/che
/che/assembly                             # Generates binary assemblies of Che
/che/assembly/assembly-main               # Final packaging phase
/che/assembly/assembly-ide-war            # Creates the IDE.war from plug-ins & core
/che/assembly/assembly-wsmaster-war       
/che/assembly/assembly-wsagent-war        # Creates the agent WAR from plug-ins & core
/che/assembly/assembly-wsagent-server     # Creates the agent server that goes into ws
/che/core                                 # Platform APIs
/che/dashboard                            # AngularJS app for managing Che
/che/plugins                              # IDE & agent plug-ins
/che/wsmaster                             # Libraries used by the Che server
/che/wsagent                              # Libraries used by agents installed into workspaces

/che-lib                                  # Forked dependencies that require mods
/che-lib/swagger
/che-lib/terminal
/che-lib/websocket
/che-lib/pty
/che-lib/che-tomcat8-slf4j-logback

# All modules in /che and /che-lib depend upon /che-dependencies
/che-dependencies                         # Maven dependencies used by che
/che-dev                                  # Code style and license header

# /che-dependencies and /che-dev depends upon /che-parent
/che-parent                               # Maven plugins and profiles
```

You can build individual directories of Che, or any of its sub-modules. These modules will generate JARs, WARs or other artifacts. The same happens if you build plug-ins of your own. These are artifacts are installed into a local maven repository that `/che/assembly` uses when creating a combined assembly.

If you build Che locally and if the necessary artifact dependencies are not locally installed into your maven repository, then Che will look in Codenvy's hosted nexus for packages. Codenvy maintains tagged versions of packages for the current SNAPSHOT and older versions.

You can see the reference to Codenvy's repositories in the `che-dependencies` repository at the end of the `pom.xml`.

```xml  
<repositories>
    <repository>
        <id>codenvy-public-repo</id>
        <name>codenvy public</name>
        <url>https://maven.codenvycorp.com/content/groups/public/</url>
    </repository>
    <repository>
        <id>codenvy-public-snapshots-repo</id>
        <name>codenvy public snapshots</name>
        <url>https://maven.codenvycorp.com/content/repositories/codenvy-public-snapshots/</url>
    </repository>
</repositories>
```
