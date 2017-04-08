Two maven modules for ws-agent represents minimum set of components that need to start workspace agent. ```che-ide-core``` is core ide part, ```che-wsagent-core``` is core server side part of workspace agent.

**How to use them**
We will use them in two ways:
 - As a fundament of our full assembly.
 - As a fundament for our samples.

**Full assembly of IDE**
To make Full assembly of ide we need to declare in assembly/assembly-ide-war/pom.xml
1. IDE Core
```
        <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-ide-core</artifactId>
        </dependency>
```
2.  All IDE plugins we have in Che.
```
     <dependency>
            <groupId>org.eclipse.che.plugin</groupId>
            <artifactId>*</artifactId>
        </dependency>
```
**Custom assembly of IDE based on minimal Che IDE**
To make Custom assembly of IDE based on minimal Che IDE* we need to declare in assembly/assembly-ide-war/pom.xml
1. IDE Core
```
        <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-ide-core</artifactId>
        </dependency>
```
2.  IDE part of custom plugin.
```
        <dependency>
            <groupId>my.plugin</groupId>
            <artifactId>plugin-json-ide</artifactId>
        </dependency>
```
3.  IDE war that will be reused to get some resources
```
       </dependency>
        <dependency>
            <groupId>org.eclipse.che</groupId>
            <artifactId>assembly-ide-war</artifactId>
            <type>war</type>
            <scope>runtime</scope>
        </dependency>
```

**Full assembly of Ws-agent server war**
1. Core Ws agent war
```
    <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-wsagent-core</artifactId>
            <type>war</type>
        </dependency>
```
2.  Swagger support
```
        <dependency>
            <groupId>org.eclipse.che.lib</groupId>
            <artifactId>che-swagger-module</artifactId>
        </dependency>
```
3.All ws-agent plugins

```
       <dependency>
            <groupId>org.eclipse.che.plugin</groupId>
            <artifactId>che-plugin-*</artifactId>
        </dependency>
```
**Custom assembly of ws-agent base minimal Che ws-agent**
1. Core Ws agent war
```
    <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-wsagent-core</artifactId>
            <type>war</type>
        </dependency>
```
2. Plugin server side
```
        <dependency>
            <groupId>my.plugin</groupId>
            <artifactId>plugin-json-server</artifactId>
        </dependency>
```
** A couple of stats  based on plugin-json**

| Value  | Basic  |  Full |
|---|---|---|
|ws-agent war size    |   17Mb | 34 MB  |
| GWT compilation  |   4min  |  6min |
| gwt scripts size  |  4,5 Mb |   7.7 Mb |
| ide war size  |   6,3Mb |   8Mb |      
                  