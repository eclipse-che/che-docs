---
tags: [ "eclipse" , "che" ]
title: Workspace Agents
excerpt: ""
layout: docs
permalink: /:categories/ws-agents/
---
{% include base.html %}

Agents are scripts that are executed after a [runtime machine]({{base}}{{site.links["ws-machines"]}}) is created. They add additional capabilities to the machines they're injected in - for example to allow terminal access or enhanced language services. Agents allow these services to be injected into machines built from stock Dockerfiles or Compose files.

# Adding Agents to a Machine  
Agents are added to [machines]({{base}}{{site.links["ws-machines"]}}) through [runtime stack]({{base}}{{site.links["ws-stacks"]}}) configuration. Eclipse Che's included stacks have been pre-configured to use certain agents. The agents needed for each pre-defined stack is determined by common tasks or file types found in [projects]({{base}}{{site.links["ide-projects"]}}).

Adding agents to your own machines can be done by editing [machine information in the user dashboard]({{base}}{{site.links["ws-machines"]}}). Note that the Java JDK is required in the stack for agents to execute.

# Adding Agents to a Custom Stack  
Stacks use JSON format for configuration. Agents are included in the machines definition. Each stack requires a machine named `dev-machine` which always requires terminal, exec and ws-agent - this machine must have a Java JDK in it for executing agents. Language server agents need to be added to the dev-machine if you want [intellisense]({{base}}{{site.links["ide-intellisense"]}}) features when using the workspace IDE.

```json  
.......
  workspaceConfig": {
    "environments": {
      "default": {
        "recipe": {
          "location": "eclipse/ubuntu_jdk8",
          "type": "dockerimage"
        },
        "machines": {
          "dev-machine": {
            "servers": {},
            "agents": [
              "org.eclipse.che.terminal",
              "org.eclipse.che.ws-agent",
              "org.eclipse.che.ssh",
              "org.eclipse.che.ls.php"
            ],
            "attributes": {
              "memoryLimitBytes": "2147483648"
            }
          }
        }
      }
    },
.......
```

# Creating New Agents  

Currently, all agents must be pre-defined within Che. We are thinking about a public registry for agents where they can be added and removed, but this is a future activity.

A new agent has to implement the [Agent interface](https://github.com/eclipse/che/blob/master/agents/che-core-api-agent-shared/src/main/java/org/eclipse/che/api/agent/shared/model/Agent.java) and be bound into the container.

```java
public interface Agent {

    /**
     * Returns the id of the agent.
     */
    String getId();

    /**
     * Returns the name of the agent.
     */
    String getName();

    /**
     * Returns the version of the agent.
     */
    String getVersion();

    /**
     * Returns the description of the agent.
     */
    String getDescription();

    /**
     * Returns the depending agents, that must be applied before.
     */
    List<String> getDependencies();

    /**
     * Returns the script to be applied when machine is started.
     */
    String getScript();

    /**
     * Returns any machine specific properties.
     */
    Map<String, String> getProperties();

    /**
     * Returns Che servers in the machine.
     */
    Map<String, ? extends ServerConf2> getServers();
}
```

Agents have an unique ID, a name, a set of other agents that they depend upon, properties, and a "script" that defines how the agent's packages have to be installed into the workspace. This script handles installation and start of the agent.

The scripts that you must provide with an agent have a large `if` block where you provide installation logic for each Linux distribution that we support. You can follow our [templates](https://github.com/eclipse/che/blob/master/agents/ls-json/src/main/resources/org.eclipse.che.ls.json.script.sh) for how to build agents of your own.

### Adding Agents

* Create a sub module in the [agents folder](https://github.com/eclipse/che/tree/master/agents)
* Create a resource file with the agent description:

```json
{
  "id": "org.eclipse.che.my-agent",
  "name": "My simple agent",
  "description": "Does some stuff :)",
  "dependencies": [],
  "properties": {}
}
```

* Create resource file with agent script:

```bash
...

unset PACKAGES
unset SUDO
command -v tar >/dev/null 2>&1 || { PACKAGES=${PACKAGES}" tar"; }
command -v curl >/dev/null 2>&1 || { PACKAGES=${PACKAGES}" curl"; }
test "$(id -u)" = 0 || SUDO="sudo"

CHE_DIR=$HOME/che

...

if echo ${LINUX_TYPE} | grep -qi "rhel"; then
    ...  

# Red Hat Enterprise Linux 6
############################
elif echo ${LINUX_TYPE} | grep -qi "Red Hat"; then
    ...

# Ubuntu 14.04 16.04 / Linux Mint 17
####################################
elif echo ${LINUX_TYPE} | grep -qi "ubuntu"; then
    ...

# Debian 8
##########
elif echo ${LINUX_TYPE} | grep -qi "debian"; then
    ...

# Fedora 23
###########
elif echo ${LINUX_TYPE} | grep -qi "fedora"; then
    ...

# CentOS 7.1 & Oracle Linux 7.1
###############################
elif echo ${LINUX_TYPE} | grep -qi "centos"; then
    ...

# openSUSE 13.2
###############
elif echo ${LINUX_TYPE} | grep -qi "opensuse"; then
    ...

else
    >&2 echo "Unrecognized Linux Type"
    >&2 cat $FILE
    exit 1
fi

...
```

* Create your own agent class extending [BasicAgent](https://github.com/eclipse/che/blob/master/agents/che-core-api-agent-shared/src/main/java/org/eclipse/che/api/agent/shared/model/impl/BasicAgent.java):

```java
@Singleton
public class MyAgent extends BasicAgent {
    private static final String AGENT_DESCRIPTOR = "<AGENT_DESCRIPTOR_RESOURCE_NAME>";
    private static final String AGENT_SCRIPT     = "<AGENT_SCRIPT_RESOURCE_NAME>";

    @Inject
    public MyAgent() throws IOException {
        super(AGENT_DESCRIPTOR, AGENT_SCRIPT);
    }
}
```

* Bind agent into the container in [WsMasterModule](https://github.com/eclipse/che/blob/master/assembly/assembly-wsmaster-war/src/main/java/org/eclipse/che/api/deploy/WsMasterModule.java):

```java
@DynaModule
public class WsMasterModule extends AbstractModule {
    @Override
    protected void configure() {
        ...

        Multibinder<Agent> agents = Multibinder.newSetBinder(binder(), Agent.class);
        agents.addBinding().to(MyAgent.class);

        ...
    }
}
```

Have a look at our example of the [JSON language server agent](https://github.com/eclipse/che/tree/master/agents/ls-json) for more ideas.
