---
tags: [ "eclipse" , "che" ]
title: Archetype
excerpt: ""
layout: docs
permalink: /:categories/archetype/
---
{% include base.html %}

We have added a new command to the CLI, `archetype` which can be used to generate custom assemblies of Eclipse Che and Codenvy.

An assembly is a bundling of extensions, plugins, stacks, agents, branding elements, and a CLI
that can be built into a new binary for distribution. In essence, an assemly is a custom che. Custom assemblies are used by Che developers and customizers to create new products with Che running embedded.

An archetype is a maven technique for generating code templates. A single archetype has an ID and
generates a complete custom assembly. Differnent archetypes generate assemblies with different
types of customizations. We make each archetype customize the minimal number of features to make
learning about customizations simpler.

Your host system must have Maven 3.3+ installed to facilitate generation and compiling of custom
assemblies. You must pass in your Maven's M2 repository path on your host. Our archetype generator
will download libraries into that repository making repeated compilations faster over time.
On most Linux based systems, your M2 is located at '/home/user/.m2' and it is '%USERPROFILE%/.m2'
for Windows. We default your M2 repository to '/home/user/.m2'. Use the '/m2' mount to change this.

Your custom assembly will be generated in the host path mounted to '/archetype'. This generates a
Maven multi-module project. You can enter the folder and build it with 'mvn clean install' or use
this utility to build it. Compiling an assembly requires other tools like Java, Angular, Go to be
installed on your host system. However, if you use this tool to compile your custom assembly we
use 'eclipse/che-dev' Docker image which contains all of these utilities preinstalled. It is simple
but is a large download >1GB and compilation is slower than using your host since the Docker
container is performing compilation against files that are host-mounted.

The syntax of the command is
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
  --archid=<id>               Different archetypes generate different types of customizations - default = plugin-menu-archetype
  --archversion=<version>     Sets archetype version - default = tag of CLI image
  --version=<version>         Sets custom assembly version - default = archetype version (CLI image tag)
  --group=<group>             Sets groupId of generated assembly - default = com.sample
  --id=<id>                   Sets artifactId of generated assembly - default = assembly
  --no:interactive            Disables interactive mode
```

We provide a variety of different archetypes that will generate custom assemblies with customizations for a small portion of Che. This is provided to simplify the learning experience for new developers with Che. Custom assemblies will add code, change some configuration files, and also add new software dependencies. Developers can then use Maven (or this `archetype` utility) to compile those changes into a package that can be run with the CLI.

For example:
```
# Eclipse Che 5.7.0 or higher
docker run -it --rm
  -v /var/run/docker.sock:/var/run/docker.sock
  -v /c/archetype:/archetype
  -v /c/tmp:/data
  -v /c/Users/Tyler/.m2/repository:/m2
    eclipse/che
      archetype all --no:interactive
```
This is syntax on Windows will:
1. Generate a custom assembly into the `C:\archetype` folder.
2. The custom assembly will accept all of the defaults without prompting the user. In this case, the ``plugin-menu-archetype` archetype will be generated with a custom menu entry that launches a custom action.
3. Archetype version will default to CLI image version which is the latest tag
4. The custom assembly's Maven dependencies will be saved to the host's maven repository located at `C:\Users\Tyler\.m2\repository`. These dependencies will be downloaded and compiled into the assembly during the build phase.
5. The CLI will launch another CLI instance to run the custom assembly with that custom assembly's data folder being `C:\tmp`.

#### Linux
On Linux, the Maven utility launched by the CLI may have problems writing files to your host system during the generation phase. To overcome this limitation, in the `docker run ...` syntax before the image name add `--user={uid}` where UID is the user identity of your current users. This user identity will be passed into the various CLI utilities to execute under that user identity.
Example
```
      -v /etc/group:/etc/group:ro \
      -v /etc/passwd:/etc/passwd:ro \
      --user=1000:1000  \
      --group-add 999 \
```
