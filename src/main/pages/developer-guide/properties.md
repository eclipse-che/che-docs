---
title: "Properties in Extensions"
keywords: framework, UI, properties
tags: [extensions, assembly, dev-docs]
sidebar: user_sidebar
permalink: properties.html
folder: developer-guide
---

{% include links.html %}

## Referencing Properties in Extensions  

You can reference properties in Che extensions that you author. Configuration parameters may be injected with a constructor or directly in the fields. The parameter of the field must be annotated with `@javax.inject.Named`. The value of the annotation is the name of the property. For example, if the configuration property is: `data_file:/home/user/storage` then in your extension code:

```java  
public class MyClass {
  ...
  @Inject
  public MyClass(@Named("data_file") File storage) {
      ...
  }
}
```

or

```java  
public class MyClass {
  @Inject
  @Named("data_file")
  private File storage;
  ...
}
```

All system properties and environment variables may be injected into your extensions with prefixes `sys.` and `env.`, respectively. So, for example, environment variable `HOME` name must be `env.HOME`. Here is an example of how to inject the value of system property `java.io.tmpdir` and value of environment variable `HOME`.

```java  
public class MyClass {
  @Inject
  public MyClass(@Named("sys.java.io.tmpdir") File tmp, @Named("env.HOME") File home) {
      ...
  }
}
```
Any value can be converted into a `java.lang.String` Java type. You can also directly convert properties to the following Java types:
  * `boolean`
  * `byte`
  * `short`
  * `int`
  * `long`
  * `float`
  * `double`
  * `java.net.URI`
  * `java.net.URL`
  * `java.io.File`
  * `String[]` (value is a comma separated string)

## Property Aliases

Sometimes a developer may need to change property name but support old names as well for the sake of backward compatibility. If this is the case, there is [aliases file](https://github.com/eclipse/che/blob/master/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che_aliases.properties) where you can map new property name to old ones:

```
current_name=old_name, very_old_name
```

A few gotchas:

* current_name = current_value
* if `old_name` property exists it will be bound to the old_value, so `current_name = old_value` and `very_old_name = old_value`
* if `very_old_name` property exists it will be bound to `very_old_value`, so `current_name = very_old_value` and `old_name = very_old_value`

**IMPORTANT**: it is prohibited to use a different name for the same property on the same level. From the example above, you can use environment property `CHE_CURRENT_NAME` and `CHE_OLD_NAME`. However, you can use it on a different level, for instance, environment property and system property.

## Workspace Extension Properties  

Each workspace is a separate runtime, and has at least one development agent that runs as a miniaturized Che server within the workspace. That agent has its own properties that can be configured as well. If you are authoring custom workspace extensions that are deployed within Che's agent in the workspace, you can customize.
