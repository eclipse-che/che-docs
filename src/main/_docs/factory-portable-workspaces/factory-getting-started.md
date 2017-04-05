---
tags: [ "eclipse" , "che" ]
title: Factory - Getting Started
excerpt: "Convert any repository into a developer workspace."
layout: docs
permalink: /:categories/getting-started/
---
{% include base.html %}

A Factory is a template used to generate new or open existing workspaces with a URL. Factories can be used to create replicas of existing workspaces or to automate the provisioning of statically or dynamically defined workspaces.

Factories are available with Eclipse Che and Codenvy.

# Try a Factory
Clone a public workspace on `codenvy.io` by clicking the button below.
[![Try a Factory ](https://codenvy.io/factory/resources/codenvy-contribute.svg){:style="width: 30%;"}{:href="http://codenvy.io/f?id=omriatu352kkthua"}](http://codenvy.io/f?id=omriatu352kkthua)

# Using Factories
Factories can be invoked from a Factory URL built in multiple ways. You can replace the {% if site.product_mini_cli=="codenvy" %}`codenvy.io` domain with the hostname of any Codenvy on-premises installation.{% else %}`localhost:8080` domain with the hostname of any Che installation.{% endif %}

{% if site.product_mini_cli=="codenvy" %}Using Factories on `codenvy.io` require the user to be authenticated. Users who are not authenticated will be presented a login screen after they click on the Factory URL.  Users without an account can create one using the same dialog.{% else %}{% endif %}

#### Invoke Factory using its unique hashcode  

| Format | `/f?id={hashcode}`<br>`/factory?id={hascode}`
| Sample | {% if site.product_mini_cli=="codenvy" %} [https://codenvy.io/f?id=s38eam174ji42vty](https://codenvy.io/f?id=s38eam174ji42vty){% else %}[https://localhost:8080/f?id=s38eam174ji42vty](https://localhost:8080/f?id=s38eam174ji42vty){% endif %}

#### Invoke a named Factory

| Format | `/f?user={username}&name={factoryname}`<br>`/factory?user={username}&name={factoryname}`
| Sample | {% if site.product_mini_cli=="codenvy" %} [https://codenvy.io/f?user=tylerjewell&name=starwars](https://codenvy.io/f?user=tylerjewell&name=starwars)<br>[https://codenvy.io/factory?user=tylerjewell&name=starwars](https://codenvy.io/factory?user=tylerjewell&name=starwars){% else %}[https://localhost:8080/f?user=che&name=starwars](https://localhost:8080/f?user=che&name=starwars)<br>[https://localhost:8080/factory?user=che&name=starwars](https://localhost:8080/factory?user=che&name=starwars){% endif %}

#### Invoke Factory for a specific git repo  

| Format | `/f?url={git URL}`
| Sample | {% if site.product_mini_cli=="codenvy" %} [http://codenvy.io/f?url=https://github.com/eclipse/che](http://codenvy.io/f?url=https://github.com/eclipse/che)<br>[http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server](http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server)<br>[http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project](http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project){% else %}[http://localhost:8080/f?url=https://github.com/eclipse/che](http://localhost:8080/f?url=https://github.com/eclipse/che)<br>[http://localhost:8080/f?url=https://github.com/eclipse/che/tree/language-server](http://localhost:8080/f?url=https://github.com/eclipse/che/tree/language-server)<br>[http://localhost:8080/f?url=https://gitlab.com/benoitf/simple-project](http://localhost:8080/f?url=https://gitlab.com/benoitf/simple-project){% endif %}

Once the Factory is executed, it either loads an existing workspace or generates a new one, depending upon the Factory configuration.  The name of the workspace is determined within the Factory configuration and its name becomes part of the URL access with the format `{hostname}/{username}/{workspace}`.


## NEXT STEPS
You have just created your first developer workspace using Factories. Read on to learn more about:
- How to [create factories]({{base}}{{site.links["factory-creating"]}}).
- Customizing factories with the [Factory JSON reference]({{base}}{{site.links["factory-json-reference"]}}).
- Factory terms in the [glossary]({{base}}{{site.links["setup-glossary"]}}).
