---
tags: [ "eclipse" , "che" ]
title: Factory - Creating
excerpt: "Creating a Factory."
layout: docs
permalink: /:categories/creating/
---
{% include base.html %}

# Creating Factories
You can create Factories that are saved with a unique hash code in the dashboard. Navigate to the `Factories` page and hit the `Create Factory` button. You can create a Factory with a pretty name in the dashboard or by invoking a URL within your workspace.  If you generate a Factory template using your workspace URL, your Factory inherits the existing definition of your workspace.

| Create New Factory   | Example   
| --- | ---
| Create a new Factory from the dashboard <br>`Dashboard > Factories > Create Factory` | [https://codenvy.io/f?id=s38eam174ji42vty](https://codenvy.com/f?id=s38eam174ji42vty)   
| Create on-demand URL Factory by specifying the remote URL In that case the configuration may be stored inside the repository. |[http://codenvy.io/f?url=https://github.com/eclipse/che](http://codenvy.io/f?url=https://github.com/eclipse/che)<br>[http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server](http://codenvy.io/f?url=https://github.com/eclipse/che/tree/language-server)<br>[http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project](http://codenvy.io/f?url=https://gitlab.com/benoitf/simple-project)

You can also author a Factory from scratch using a `factory.json` file and then generating a Factory URL using our CLI or API. Learn more about [Factory JSON reference]({{base}}{{site.links["factory-json-reference"]}})

# URL Factories  
URL Factories are working with github and gitlab repositories. By using URL Factories, the project referenced by the URL is imported.

URL can include a branch or a subfolder. Here is an example of url parameters:
- `?url=https://github.com/eclipse/che` che will be imported with master branch
- `?url=https://github.com/eclipse/che/tree/5.0.0` che is imported by using 5.0.0 branch
- `?url=https://github.com/eclipse/che/tree/5.0.0/dashboard` subfolder dashboard is imported by using 5.0.0 branch

## Customizing URL Factories
There are 2 ways of customizing the runtime and configuration

**Customizing only the runtime**
Providing a `.factory.dockerfile` inside the repository will signal to the {{ site.product_mini_name }} URL Factory to use this dockerfile for the workspace agent runtime. By default imported projects are set to a `blank` project type, however project type can be set in the `.factory.json` or workspace definition that the Factory inherits from.

**Customizing the project and runtime**
Providing a `.factory.json` file inside the repository will signal to the {{ site.product_mini_name }} URL Factory to configure the project and runtime according to this configuration file. When a `.factory.json` file is stored inside the repository, any `.factory.dockerfile` content is ignored as the workspace runtime configuration is defined inside the JSON file.




{% if site.product_mini_cli=="codenvy" %}
# Repository Badging  

If you have projects on GitHub or Gitlab, you can help your contributors to get started by providing them ready-to-code developer workspaces. Create a factory and add the following badge on your repositories `readme.md`:
![https://codenvy.io/factory/resources/codenvy-contribute.svg](https://codenvy.io/factory/resources/codenvy-contribute.svg)

Use the following Markdown syntax:
```markdown  
[![Developer Workspace](https://codenvy.io/factory/resources/codenvy-contribute.svg)](your-factory-url)
```
{% endif %}


## NEXT STEPS
Read on to learn more about:
- [Factory JSON Reference]({{base}}{{site.links["factory-json-reference"]}}).
- [Glossary]({{base}}{{site.links["factory-glossary"]}}).
