---
tags: [ "eclipse" , "che" ]
title: Assembly Dev Lifecycle
excerpt: "An assembly is a packaging of Che libraries, extensions, agents, and branding elements to create a new Che distribution."
layout: docs
permalink: /:categories/dev-lifecycle/
---
{% include base.html %}
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
```shell
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

# Generate
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

If we wanted to generate the custom assembly code without compiling it, we would run:
```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock 
  -v /c/archetype:/archetype 
  -v /c/tmp:/data 
  -v /c/Users/Tyler/.m2/repository:/m2 
    eclipse/che-cli:5.4.0 
      archetype generate
```

#### Linux
On Linux, the Maven utility launched by the CLI may have problems writing files to your host system during the generation phase. To overcome this limitation, in the `docker run ...` syntax add `--user={uid}` before the image name where `uid` is the user identity of your current users. This user identity will be passed into the various CLI utilities to execute under that user identity.

#### Archetypes List
We provide different archetypes that will generate custom assemblies with different types of customizations. You can see the list of available archetypes by running the `archetype` command without `--no:interactive`. You will be prompted to choose from a list. These archetypes are provided as small sets of customization to simplify the learning experience for new developers with Che. For each of the archetypes that we provide, we also have a short section discussing the relevant elements modified to make the assembly work.

Each archetype has a unique artifactId, which you can specify on the command line with `--archid`. We also generate new versions of each archetype during each release of Che. You can choose a specific version of the archetype with the `--archversion` parameter.

The full list of custom assemblies that you can generate is documented in the CLI and also on the repository for the [assembly generator](https://github.com/eclipse/che-archetypes/blob/master/README.md).

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
    eclipse/che-cli:5.4.0 
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
If this were a Linux system, there would be additional volume mounts required and you must set the user identity with `--user`. The full syntax for this Docker image is [within the Che repository](https://github.com/eclipse/che/blob/master/dockerfiles/dev/Dockerfile).

#### Native
While the Docker approach to compiling an assembly is simple, it is slower. You can perform a native build with `mvn clean install` in the root of the assembly (the folder with the `pom.xml`) or any module that is a sub-folder within the assembly. If you have the right utilities installed, Maven will go about downloading necessary dependencies, perform compilation, execute unit tests, and give you a custom assembly. The custom assembly is placed into the `/target` sub-folder of the assembly that is built. 

Compiling an assembly requires other tools like Java, Angular, Go to be installed on your host system. Each module of the assembly requires different dependencies. You can view the README.md in Che's source repository for the requirements to build that module. We also discuss many of the requirements and techniques for improving build performance [in the Che wiki](https://github.com/eclipse/che/wiki/Development-Workflow) where the internal development workflow is discussed.

# Run
A custom assembly is packaged into a set of binaries that can be used with the Che Docker image to launch Che servers. The finalized build is located in `assembly/assembly-main/target`. 

You can run this custom assembly either by using the `archetype` command or with the Che CLI. The `archetype run` action will use your assembly details and launch the Che CLI automatically with the proper location of the custom assembly. Given the example we have started, this would look like (note that mounting the M2 repository is not required as we are not building with Maven):

```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock 
  -v /c/archetype:/archetype 
  -v /c/tmp:/data 
    eclipse/che-cli:5.4.0 
      archetype run
```

Optionally, you can use the Che CLI to run a custom assembly by mounting `/assembly` to the exploded location of the assembly that has already been built. While developing Che and Codenvy itself, our engineers keep a branch open, work on customizations, and then build those customizations into an assembly that they mount with the CLI. 

The exploded assembly is usually something like `assembly/assembly-main/target/eclipse-che-<version>/eclipse-che-<version>/`. You can use the rest of the CLI's options and parameters as you normally would. For example, given the sample we started with, the CLI direct launch equivalent would be:
```
docker run -it --rm --name run-che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /c/tmp:/data \
           -v /c/archetype/assembly/assembly-main/target/eclipse-che-5.4.0/eclipse-che-5.4.0:/assembly \
              eclipse/che:5.4.0 start --skip:nightly"
```

# Stop
You can stop a custom assembly with the CLI's `stop` command or with `archetype stop`:
```
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock 
  -v /c/archetype:/archetype 
  -v /c/tmp:/data 
    eclipse/che-cli:5.4.0 
      archetype stop
```

# Che vs. Codenvy
The `archetype generate` command will generate two custom assemblies: one for Eclipse Che and one for Codenvy, which is an enterprise adaptation of Che that adds multi-node scalability, a user database, and security controls. Eclipse Che extensions are deployable within a Codenvy custom assembly. There are some elements of configuration that are slightly different between the assemblies, so we provide both to provide comparison between the various packages.

The Eclipse Che and Codenvy CLI have (mostly) identical syntax, so you can build and run either custom assembly. By default, the `archetype build` and `archetype run` commands default to the Che custom assembly.  You can switch to the Codenvy assembly by appending `--codenvy` to either command.

# Customizing
Our archetypes generate a functional custom assembly with some pre-built customizations. You can further customize an assembly by either a) excluding plugins or assets from Che / Codenvy, b) including new plugins or assets that you have created, or c) both. For example, if you want to replace Che's git plugin with an improvement that you make, you would both exclude the default one provided by Che and then include a new plugin that you author.

#### Exclude
#### Include

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

# Production Mode
TODO: Discuss how to take a custom assembly that is ready for deployment and then package it within a custom Docker image to replace `eclipse/che-server` with a new image that contains a custom assembly's binaries.
