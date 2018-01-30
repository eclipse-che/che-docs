---
title: "What Are Factories?"
keywords: chedir, factories
tags: [chedir, factories]
sidebar: user_sidebar
permalink: factories.html
folder: portable-workspaces
---

{% include links.html %}

## Intro

A factory is a concept that automates the generation or loading of a workspace using URLs.

Factories make it possible to execute many of the automation capabilities contained within a Chefile, but in a purely remote syntax. Factories are URLs that you give to others, that when executed by other developers, will generate new workspaces in those acceptors' accounts with cloned projects and ready-to-go commands. Factories are wrapped with policies so that the Factory owner can control when, how, and who is able to make use of the Factory without the acceptors' having to pre-configure any software on their computer.

You can create Chefiles for a local directory from an existing Factory. Or, you can have Che automatically generate a Factory for a source repository that has a Chefile in the root of the repository. Think of factory as a way for you to allow remote users to execute Chedir up against a repository without those users having to install anything first.

## Create Factory From Chefile
You can create a factory to load within Codenvy from an existing Chefile. In the directory that has your Chefile execute:

```shell  
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock
                    -v <path>:/data
                    -v <path-to-project>:/chedir
                       eclipse/che:<version> dir factory
```

This will output a factory object that can be imported into any Che installation. Once imported, you will have a URL that can be shared with others allowing for remote execution of the Chedir up capability.

Note: Che is also searching for .Chefile name (hidden file on Linux/MacOs) in addition to Chefile.
