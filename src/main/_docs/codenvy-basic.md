Two maven modules for ws-agent represents  minimum set of components that need to start workspace agent. ```codenvy-ide-core``` is core ide part, ```codenvy-wsagent-core``` is core server side part of workspace agent.

**How to use them**
We will use them in two ways:
 - As a fundament of our full assembly.
 - As a fundament for our samples.

**Full assembly of IDE**
To make Full assembly of ide we need to declare in assembly/compiling-ide-war/pom.xml
1. IDE Core
```
        <dependency>
            <groupId>org.eclipse.che.core</groupId>
            <artifactId>che-ide-core</artifactId>
        </dependency>
```
2.  All IDE plugins we have in Codenvy.
```
        <dependency>
            <groupId>com.codenvy.plugin</groupId>
            <artifactId>codenvy-plugin-*</artifactId>
        </dependency>
```
3.  All IDE plugins we have in Che.
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


**Custom assembly of IDE based on minimal Codenvy IDE**
To make Custom assembly of IDE based on minimal Codenvy IDE* we need to declare in assembly/assembly-ide-war/pom.xml
1. Codenvy IDE Core
```
        <dependency>
            <groupId>com.codenvy.onpremises</groupId>
            <artifactId>codenvy-ide-core</artifactId>
            <scope>provided</scope>
        </dependency>
```
2.  IDE part of custom plugin.
```
        <dependency>
            <groupId>my.plugin</groupId>
            <artifactId>plugin-json-ide</artifactId>
            <scope>provided</scope>
        </dependency>
```
3.  IDE war that will be reused to get some resources
```
        <dependency>
            <groupId>com.codenvy.onpremises</groupId>
            <artifactId>assembly-ide-war</artifactId>
            <type>war</type>
            <scope>runtime</scope>
        </dependency>
```

**Full assembly of Ws-agent server war**
1. Core Ws agent war
```
        <dependency>
            <groupId>com.codenvy.onpremises.wsagent</groupId>
            <artifactId>codenvy-wsagent-core</artifactId>
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
3.All Codenvy ws-agent plugins

```
        <dependency>
            <groupId>com.codenvy.plugin</groupId>
            <artifactId>codenvy-plugin-*</artifactId>
        </dependency>
```
4.All Che ws-agent plugins

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

**Custom assembly of ws-agent base minimal Codenvy ws-agent**
1. Core Ws agent war
```
        <dependency>
            <groupId>com.codenvy.onpremises.wsagent</groupId>
            <artifactId>codenvy-wsagent-core</artifactId>
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