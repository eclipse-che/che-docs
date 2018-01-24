---
title: "IDE Extensions: GWT"
keywords: framework, extensions, gwt, client side
tags: [extensions, assembly, dev_docs]
sidebar: user_sidebar
permalink: ide-extensions-gwt.html
folder: extensibility
---

{% include links.html %}


## IDE Extension Structure

Let's take a closer look at how an IDE extension should be structured:

```
ide
├─ src                                              // sources folder
│  └─ main
│     ├─ java
│     │  └─ org.eclipse.che.plugin.menu.ide
│     │     ├─ ...
│     │     ├─ inject
│     │     │  └─ SampleMenuGinModule.java          // GIN module
│     │     └─ SampleMenuExtension.java             // IDE extension class
│     ├─ resources
│     │  └─ org.eclipse.che.ide.ext.demo.client
│     └─ module.gwt.xml                             // template for generating GWT module [1]
├─ target                                           // build output
│  └─ classes
│     ├─ META-INF
│     │  └─ gwt
│     │     └─ mainModule                           // contains GWT module name [2]
│     └─ org.eclipse.che.plugin.menu
│        ├─ ...
│        └─ SampleMenuExtension.gwt.xml             // generated GWT module [3]
└─ pom.xml
```
Links: [1](https://tbroyer.github.io/gwt-maven-plugin/generate-module-mojo.html) [2](https://tbroyer.github.io/gwt-maven-plugin/generate-module-metadata-mojo.html) [3](https://tbroyer.github.io/gwt-maven-plugin/generate-module-mojo.html)


## pom.xml

There are several important parts in the pom.xml of the Che IDE plugin:

* Packaging of the Maven project is `gwt-lib` which triggers [`gwt-lib`](https://tbroyer.github.io/gwt-maven-plugin/lifecycles.html#GWT_Library:_gwt-lib) Maven lifecycle that will build a [GWT library](https://tbroyer.github.io/gwt-maven-plugin/artifact-handlers.html#GWT_Library:_gwt-lib):
  ```xml
  <packaging>gwt-lib</packaging>
  ```
* Dependency on the Che IDE API library that provides a [set of APIs](https://docs.google.com/spreadsheets/d/1ijapDnl1G7svy7sIKgTntyTuVsnd9nFcH0-357C0MxE/edit#gid=0) for extending Che IDE:

  ```xml
  <dependency>
      <groupId>org.eclipse.che.core</groupId>
      <artifactId>che-core-ide-api</artifactId>
  </dependency>
  ```
* Name of the GWT module is defined in the configuration of `gwt-maven-plugin`:

  ```xml
  <plugin>
      <groupId>net.ltgt.gwt.maven</groupId>
      <artifactId>gwt-maven-plugin</artifactId>
      <extensions>true</extensions>
      <configuration>
          <moduleName>org.eclipse.che.plugin.menu.SampleMenuExtension</moduleName>
      </configuration>
  </plugin>
  ```
For details on the generating GWT module, read the `gwt:generate-module` [mojo description](https://tbroyer.github.io/gwt-maven-plugin/generate-module-mojo.html). GWT library is a JAR that contains compiled classes, project's (re-)sources, GWT module descriptor (`*.gwt.xml`) and possibly other GWT-specific files.

## gwt.xml

Project's `*.gwt.xml` file is generated within the `gwt-lib` Maven lifecycle and contains:
- the declarations for the default source folders:
  ```xml
  <source path="client"/>
  <source path="shared"/>
  <super-source path="super"/>
  ```
- `<inherits/>` directives for the project's *direct* dependencies which were packaged as a `gwt-lib`.

*Optional* template may be provided in `src/main/module.gwt.xml` for generating project's `*.gwt.xml` file.

The most common cases when you may require a template:
- need to override the default source folders, like [here](https://github.com/eclipse/che/blob/f15fbf1cb1248d18acc3ee6fdc41766946ea4a3b/plugins/plugin-java/che-plugin-java-ext-lang-client/src/main/module.gwt.xml#L18);
- need to add `<inherits/>` directive for a GWT lib that isn't packaged as a `gwt-lib` artifact (doesn't contain GWT-specific meta information).

## Consuming Shared Libs

The shared libraries don't require any GWT-specific files or configuration in pom.xml to be consumed by a GWT library.

To use shared code in a GWT library:
- declare a dependency on the "normal" artifact (JAR with compiled classes);
- declare a dependency on the "sources" artifact (with `<classifier>sources</classifier>`).

See an example [here](https://github.com/eclipse/che/blob/19f5fd1f5ae8f165b7306e71cb0d58c2082fafab/plugins/plugin-python/che-plugin-python-lang-ide/pom.xml#L49-L57).

## IDE extension class

Che IDE plugin has an entry point - Java class annotated with an [`@org.eclipse.che.ide.api.extension.Extension`](https://github.com/eclipse/che/blob/master/ide/che-core-ide-api/src/main/java/org/eclipse/che/ide/api/extension/Extension.java) annotation. Plugin entry point is called immediately after initializing the core part of the Che IDE.

Here's an entry point of the plugin that will add a new top level menu group using [IDE actions][actions]:

```java
package org.eclipse.che.plugin.menu.ide;

import static org.eclipse.che.ide.api.action.IdeActions.GROUP_HELP;
import static org.eclipse.che.ide.api.action.IdeActions.GROUP_MAIN_MENU;
import static org.eclipse.che.ide.api.constraints.Anchor.AFTER;

import com.google.inject.Inject;
import org.eclipse.che.ide.api.action.ActionManager;
import org.eclipse.che.ide.api.action.DefaultActionGroup;
import org.eclipse.che.ide.api.constraints.Constraints;
import org.eclipse.che.ide.api.extension.Extension;
import org.eclipse.che.plugin.menu.ide.action.SampleAction;

@Extension(title = "Sample Menu")
public class SampleMenuExtension {

  private static final String SAMPLE_GROUP_MAIN_MENU = "Sample";

  @Inject
  private void prepareActions(SampleAction sampleAction, ActionManager actionManager) {

    DefaultActionGroup mainMenu = (DefaultActionGroup) actionManager.getAction(GROUP_MAIN_MENU);

    DefaultActionGroup sampleGroup =
        new DefaultActionGroup(SAMPLE_GROUP_MAIN_MENU, true, actionManager);
    actionManager.registerAction("sampleGroup", sampleGroup);
    mainMenu.add(sampleGroup, new Constraints(AFTER, GROUP_HELP));

    actionManager.registerAction("sayHello", sampleAction);
    sampleGroup.add(sampleAction, Constraints.FIRST);
  }
}
```

## Dependency Injection

Che IDE use [Google GIN](https://code.google.com/archive/p/google-gin/) for dependency injection. Che IDE plugin can provide a GIN module. In order to be picked-up by IDE, plugin's GIN module should be annotated with an [`@org.eclipse.che.ide.api.extension.ExtensionGinModule`](https://github.com/eclipse/che/blob/master/ide/che-core-ide-api/src/main/java/org/eclipse/che/ide/api/extension/ExtensionGinModule.java) annotation.

Here's a GIN module of the plugin:

```java
package org.eclipse.che.plugin.menu.ide.inject;

import com.google.gwt.inject.client.AbstractGinModule;
import org.eclipse.che.ide.api.extension.ExtensionGinModule;

@ExtensionGinModule
public class SampleMenuGinModule extends AbstractGinModule {

  @Override
  protected void configure() {}
}
```

In this example an extension GIN module isn't really necessary since the plugin does not really need to put anything in a container. Read more about [dependency injection][guice] and take a look at [example Gin modules](https://github.com/eclipse/che/blob/master/plugins/plugin-csharp/che-plugin-csharp-lang-ide/src/main/java/org/eclipse/che/plugin/csharp/ide/inject/CSharpGinModule.java).


## Extension Points

You can provide or customize existing [actions][actions], [parts][parts], [themes][themes] and [editor][editor]. This example has registered a new action.

## Debugging With Super DevMode

There are two options available to launch GWT Super DevMode, depending on the state of the Che sources: whether it's built or not since a lot of sources are generated during the Maven build.

- Case 1: Che sources have been already built. Use the following command:

`mvn gwt:codeserver -pl :che-ide-gwt-app -am -Dmaven.main.skip -Dmaven.resources.skip -Dche.dto.skip -Dskip-enforce -Dskip-validate-sources`

- Case 2: Che sources haven't been built, e.g. freshly cloned or after executing `mvn clean` or you just don't need to build the whole project. Use the following command:

`mvn gwt:codeserver -pl :che-ide-gwt-app -am -Dskip-enforce -Dskip-validate-sources`

The second one requires *more time* to launch GWT CodeServer since it executes `process-classes` build phase for each maven module. Thus, using the first command is preferable.

**Note**, both commands have to be performed in the root folder of the Che project.

Once codeserver is started, open the prompted URL, drag bookmarks on your bookmarks bar. Note that you may face the error saying there are no GWT modules on the page. It happens because the IDE is opened in an iframe. Just, cut `dashboard/#/ide/` from the URL. To debug client side code, follow instructions from [quickstart](che_in_che_quickstart.html#develop-and-debug-client-side).


## Run in Che

Once your extension is ready, you can build, run and debug it in [Che itself][che_in_che_quickstart]. Just use an existing sample and add a custom plugin with its dependencies.

## Add to a Custom Assembly

You can build your custom [Che assembly][assemblies] outside Che and/or use any IDE to develop extensions. Once done, run `mvn clean install` in the root of the assembly to get a Tomcat bundle that is ready to be run either in [Docker](docker-config.html#development-mode) or deployed to [OpenShift](openshift-config#development-mode).
