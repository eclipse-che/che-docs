---
title: Che Assemblies
sidebar: user_sidebar
keywords: dev docs
tags: [extensions, assembly]
permalink: assemblies.html
folder: extensibility
---
{% include links.html %}

## What Is a Che Assembly?

An assembly is a Maven module that produces a build artifact. In case of [Eclipse Che](https://github.com/eclipse/che/tree/master/assembly), this is either a `.war` with `jars` in it, or a Tomcat assembly, which is a Tomcat web server with custom configuration and artifacts, copied to `webapps`. The following are Eclipse Che assemblies:

| Che Assembly              | What Is Included |
| ------------------------- | ---------------- |
| `assembly-ide-war`        | GWT plugins that will be compiled into a new browser IDE as JavaScript |
| `assembly-wsagent-war`    | Java plugins that will run within a workspace agent, deployed as `.war` artifact with numerous jars in it |
| `assembly-wsagent-server` | Packages workspace agent into a Tomcat that is then launched in a machine |
| `assembly-wsmaster-war`   | Java plugins that will run within Che core server - master |
| `assembly-main`           | Packages all Che modules (including those listed above) into a final Tomcat bundle |


## assembly-ide-war

Successful build of this module produces `ide.war` that is then deployed with Tomcat (produced by `assembly-main`) as `ROOT.war` that contains a handful or jars as dependencies and what's more important - `_app` directory with JavaScript, CSS and other resources that are loaded into `IDE.html` when IDE is initialized.

This module inherits [`che-ide-gwt-app`](https://github.com/eclipse/che/blob/da18cd1867210f87a6071ed65930fb47fb8bb775/ide/che-ide-gwt-app/pom.xml) that it its turn has [`che-ide-full`](https://github.com/eclipse/che/blob/5a6d3910b268feb3c4e67c2ff9aa5640410bf777/ide/che-ide-full/pom.xml) in dependencies. So, `che-ide-full` is where all of the client side plugin dependencies are declared.

However, if you build a custom assembly and your plugin provides client side changes, it is root pom.xml of **assembly-ide-war** that dependencies should be added to. See: [IDE Extensions][ide-extensions-gwt].

This is the module that is most often extended with custom plugins.

## assembly-wsagent-war

Build artifact of this module contains all server side plugins components packaged as jars. Root `pom.xml` contains dependencies to all plugins that get deployed with the workspace agent, and this is where dependencies to custom plugins should be added. Once built, `assembly-wsagent-war` is copied to `webapps` of ws-agent Tomcat as `ROOT.war`. This is the module that is most often extended with custom plugins.

## assembly-wsagent-server

This module packages `ROOT.war` into Tomcat's `webapps` and adds configuration files. This tomcat is packaged as tar.gz archive that is then placed into main Tomcat produced by `assembly-main` build.


## assembly-wsmaster-war

The core of Che platform as a workspace server that includes [workspace API][workspaces_rest-api], user profile and settings, [implementation of runtime infrastructure][spi-implementation]. Usually used as a dependency in custom assemblies, however, it is possible to extend it, for example, by providing support of a new infrastructure.

## assembly-main

This module's name speaks for itself - this is the main assembly that packages all Che components into a Tomcat server. These components include wsmaster as `api.war`, User Dashboard as `dashboard.war`, documentation - `docs.war` and Swagger UI - `swagger.war`, agents like terminal and ws-agent (those are packaged into `lib` directory in the root of the resulting archive where Che master picks them up and serves, thus making them downloadable for [installers][installers]).

## Custom Assemblies

You may build own custom assembly of Che. To do so, there's no need to clone/copy the entire Che source code. All artifacts can be used as dependencies. Moreover, unlike assemblies in Che source code, custom assemblies can use minimal artifacts for server and client side.

Here's an [example](https://github.com/che-samples/che-ide-server-extension) of a custom Che assembly that brings in two plugins - server- and client-side. You may clone this repository and use it as a basis for your custom Che assembly.

Note that this example uses core artifacts as dependencies both for [client](https://github.com/che-samples/che-ide-server-extension/blob/master/assembly/assembly-ide-war/pom.xml#L31-L35):

```xml
<dependency>
    <groupId>org.eclipse.che.core</groupId>
    <artifactId>che-ide-core</artifactId>
    <type>gwt-lib</type>
</dependency>
```

and [server side](https://github.com/che-samples/che-ide-server-extension/blob/master/assembly/assembly-wsagent-war/pom.xml#L22-L26)

```xml
<dependency>
    <groupId>org.eclipse.che.core</groupId>
    <artifactId>che-wsagent-core</artifactId>
    <type>war</type>
</dependency>
```

Core artifacts contain a bare minimum set of platform components and plugins to be able to create and start a workspace, create or import a project, open and edit files in the editor.

You may use full artifacts that include all standard Che plugins:

Client side:

```xml
<dependency>
    <groupId>org.eclipse.che.core</groupId>
    <artifactId>che-ide-full</artifactId>
    <type>gwt-lib</type>
</dependency>


You may include a full IDE artifact and exclude a particular plugin:

```xml
<dependencies>
   <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-ide-full</artifactId>
      <exclusions>
         <exclusion>
            <artifactId>che-plugin-product-info</artifactId>
            <groupId>org.eclipse.che.plugin</groupId>
         </exclusion>
      </exclusions>
  </dependency>
</dependencies>
<build>
    <plugins>
       <plugin>
          <groupId>org.eclipse.che.core</groupId>
          <artifactId>che-core-gwt-maven-plugin</artifactId>
          <version>${project.version}</version>
          <executions>
             <execution>
                <goals>
                   <goal>process-excludes</goal>
                </goals>
             </execution>
          </executions>
       </plugin>
    </plugins>
 </build>
```

Server side:

...xml

<dependency>
    <groupId>org.eclipse.che</groupId>
    <artifactId>assembly-wsagent-war</artifactId>
    <type>war</type>
</dependency>
```

These two `pom.xml` files are entrypoints to adding custom plugins. This assembly includes two plugins that are declared in:

* [root pom.xml](https://github.com/che-samples/che-ide-server-extension/blob/master/pom.xml#L54-L64) - artifact version defaults to project version. These dependencies need to be declared to follow dependency convergence rules in Che (i.e. all dependencies have to be declared either in Che `maven-depmgt-pom` or in a root pom of an assembly). What `maven-depmgt-pom` parent brings is a set of enforcer plugins, like formatting, dependency management, source validation etc.

```xml
<dependency>
    <groupId>org.eclipse.che.sample</groupId>
    <artifactId>plugin-serverservice-server</artifactId>
    <version>${project.version}</version>
</dependency>
```

* [assembly-ide-war pom](https://github.com/che-samples/che-ide-server-extension/blob/master/assembly/assembly-ide-war/pom.xml#L36-L40):

```xml
<dependency>
    <groupId>org.eclipse.che.sample</groupId>
    <artifactId>plugin-serverservice-ide</artifactId>
    <type>gwt-lib</type>
</dependency>
```

This way, your client side plugin is included into `ide.war`. We use [Maven's overlays feature](https://maven.apache.org/plugins/maven-war-plugin/overlays.html) to package custom plugins into the resulting artifact.


* [assembly-wsmaster-war pom](https://github.com/che-samples/che-ide-server-extension/blob/master/assembly/assembly-wsagent-war/pom.xml#L27-L30):

```xml
<dependency>
    <groupId>org.eclipse.che.sample</groupId>
    <artifactId>plugin-serverservice-server</artifactId>
</dependency>
```

Your custom plugin packaged as jar is automatically added to inherited `wsagent` artifact if both are declared as dependencies in `pom.xml`. As a result, the final `.war` artifact will contain a custom jar.

## Update Assembly

In a `pom.xml` update both:

```xml
<parent>
    <artifactId>maven-depmgt-pom</artifactId>
    <groupId>org.eclipse.che.depmgt</groupId>
    <version>6.0.0-M4</version>
</parent>
```
and

```xml
<properties>
    <che.version>6.0.0-M4</che.version>
</properties>
```

It is important to keep those versions consistent to avoid build failures and incompatibilities. It is also recommended to keep versions of own artifacts aligned with a parent version.

## Next Steps

Now that you have got some knowledge about Che assemblies and own cloned a sample assembly, let's take a closer look at Eclipse Che [client][ide-extensions-gwt] and [server-side][server-side-extensions] plugins.
