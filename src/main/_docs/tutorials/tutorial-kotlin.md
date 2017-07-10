---
tags: [ "eclipse" , "che" ]
title: Kotlin Hello World
excerpt: ""
layout: tutorials
permalink: /:categories/kotlin/
---
{% include base.html %}

# Create Kotlin Workspace

Kotlin stack can be found in stack library, or your can create a custom stack from the following recipe:

```
FROM eclipse/kotlin
```

# Create a Project

Create a blank project at Workspace > Create Project > Blank. Create `hello.kt` file with the following content:

```
fun main(args: Array<String>) {
    println("Hello, world!")
}
```

# Create a command

Now, let's compile a jar and execute it. Create a new command with the following syntax:

```
cd ${current.project.path}
kotlinc hello.kt -include-runtime -d hello.jar
java -jar hello.jar
```
