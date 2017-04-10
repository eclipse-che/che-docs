Two maven modules for ws-agent represents minimum set of components of a workspace agent that need to start workspace agent. 

- ```che-ide-core```: Core ide component.
- ```che-wsagent-core```: Core server side component.

**How to use them**
We will use them as fundaments in two ways:
 - Full assembly.
 - Samples.

**Full assembly of IDE**
To make full assembly of ide we need to declare in assembly/assembly-ide-war/pom.xml.
1. IDE Core
```
        <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-ide-core</artifactId>
        </dependency>
```
2.  All IDE plugins we have in Che
```
        <dependency>
           <groupId>org.eclipse.che.plugin</groupId>
           <artifactId>*</artifactId>
        </dependency>
```
**Minimal assembly of IDE**
To make minimal assembly we need to declare in assembly/assembly-ide-war/pom.xml.
1. IDE Core
```
        <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-ide-core</artifactId>
        </dependency>
```
2.  IDE custom plugin
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

**Full assembly of ws-agent server war**
1. Core ws-agent war
```
    <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-wsagent-core</artifactId>
            <type>war</type>
        </dependency>
```
2. Swagger support
```
        <dependency>
            <groupId>org.eclipse.che.lib</groupId>
            <artifactId>che-swagger-module</artifactId>
        </dependency>
```
3. All ws-agent plugins

```
       <dependency>
            <groupId>org.eclipse.che.plugin</groupId>
            <artifactId>che-plugin-*</artifactId>
        </dependency>
```
**Custom assembly of ws-agent base minimal Che ws-agent**
1. Core ws-agent war
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
                  
