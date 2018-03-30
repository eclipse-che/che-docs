---
title: Che logging
sidebar: user_sidebar
keywords: dev docs
tags: [extensions, assembly, logging, log, logs]
permalink: logging.html
folder: developer-guide
---
{% include links.html %}

## Logging in Che
By default ws-master and ws-agent are configured to use logback as default logging backend. Their configuration produces plaintext logs to output of Che assembly and stores it to files.
There are several options on how to customize logs producing in Che.
Che is bundled with 2 variants of logger format and location settings `json` and `plaintext`.  
JSON setting produces logs in JSON stream format and doesn't store them in any files.  
Plaintext setting produces logs in the format of plain text and stores it in directory Che logs dir.  
To switch these encodings set environment variable `CHE_LOGS_APPENDERS_IMPL` to `json` or `plaintext`. Value `plaintext` is default setting.

To add a custom implementation of logger producing create [custom assembly][assemblies], set environment variable `CHE_LOGS_APPENDERS_IMPL=myimpl` and add files `logback-file-myimpl-appenders.xml` and `tomcat-file-myimpl-appenders.xml` to `tomcat/conf` folder.  
An example of these files which adds storing logs in JSON format in files:  
logback-file-json-appenders.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<included>
    <appender name="file-json" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${che.logs.dir}/logs/catalina.log.json</file>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
          <level>info</level>
        </filter>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${che.logs.dir}/archive/%d{yyyy/MM/dd}/catalina.log.json</fileNamePattern>
            <maxHistory>${max.retention.days}</maxHistory>
        </rollingPolicy>
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeMdcKeyName>identity_id</includeMdcKeyName>
            <includeMdcKeyName>req_id</includeMdcKeyName>
        </encoder>
    </appender>

    <root level="${che.logs.level:-INFO}">
        <appender-ref ref="file-json"/>
    </root>
</included>
```
tomcat-file-json-appenders.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<included>
    <appender name="file-json" class="org.apache.juli.logging.ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${che.logs.dir}/logs/catalina.log.json</file>
        <filter class="org.apache.juli.logging.ch.qos.logback.classic.filter.ThresholdFilter">
          <level>info</level>
        </filter>
        <rollingPolicy class="org.apache.juli.logging.ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${che.logs.dir}/archive/%d{yyyy/MM/dd}/catalina.log.json</fileNamePattern>
            <maxHistory>${max.retention.days}</maxHistory>
        </rollingPolicy>
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeMdcKeyName>identity_id</includeMdcKeyName>
            <includeMdcKeyName>req_id</includeMdcKeyName>
        </encoder>
    </appender>

    <root level="${che.logs.level:-INFO}">
        <appender-ref ref="file-json"/>
    </root>
</included>
``` 
Other `logback-logstash-encoder` appenders can be added as well. See <https://github.com/logstash/logstash-logback-encoder#usage>.    
Note that to change logging settings for workspace environment variable should be set in workspaces and assembly of ws-agent should be extended in addition to the same actions for Che master.  
On the other hand, customizing of ws-agent logs is uncommon practise, so it can be avoided.  

Also, there are two ways to extend chosen configuration.
1. Put your configuration in `${che.local.conf.dir}/logback/logback-additional-appenders.xml` or `${catalina.home}/conf/logback-additional-appenders.xml` file
2. Provide environment variable in such form 
```
CHE_LOGGER_CONFIG=logger1=logger1_level,logger2=logger2_level
```
for example
```
CHE_LOGGER_CONFIG=org.eclipse.che=DEBUG,org.eclipse.che.api.installer.server.impl.LocalInstallerRegistry=OFF 
```
