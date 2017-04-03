---
tags: [ "eclipse" , "che" ]
title: Factory - Glossary
excerpt: "Specific terms used across documentation for Factories."
layout: docs
permalink: /:categories/factory-glossary/
---
{% include base.html %}

# Definitions  
Below are a list of some {{ site.product_mini_name }} specific terms that we use across documentation for Factories.

**Factory**
: A URL that, when clicked, generates a new or loads an existing workspace, and then onboards the user into that workspace.

**Factory Configuration**
: A JSON object that defines the rules and behavior for how the Factory should work.

**Workspace Configuration**
: A JSON object that defines the contents and structure of a workspace. A workspace configuration is used within a Factory Configuration to define the workspace to be generated.

**Owner**
: A JSON object that defines the contents and structure of a workspace. A workspace configuration is used within a Factory Configuration to define the workspace to be generated.

**Acceptor**  
: Any user that clicks on a Factory URL to open or generate a workspace. The acceptor is the owner the workspace created by the Factory.  


## NEXT STEPS
Read on to learn more about:
- [Using Factory]({{base}}{{site.links["factory-creating"]}}).
- [Creating Factory]({{base}}{{site.links["factory-creating"]}}).
- [Factory JSON Reference]({{base}}{{site.links["factory-json-reference"]}}).
