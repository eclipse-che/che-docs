---
title: "DAO"
keywords: framework, overview, master, server, dao, database
tags: [dev_docs]
sidebar: user_sidebar
permalink: dao.html
folder: framework
---

{% include links.html %}

Data access object (DAO) is an object that provides an interface of persisting objects of some domain in some storage. It provides an API of storing data objects into a database without exposing any details about which database is used or, in general, any specific details about an actual way of persisting data. Eclipse Che persists the following objects:

* Users, user profile and preferences
* Accounts
* [Workspaces][what_are_workspaces]
* [Factories][factories_getting_started]
* [Stacks][stacks]
* [Permissions][permissions]
* [Installers][installers]
* [Organizations and members][organizations]

Examples of DAO in Che:

- [User DAO](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-user/src/main/java/org/eclipse/che/api/user/server/spi/UserDao.java) and an example of its implementation [JpaUserDao](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-user/src/main/java/org/eclipse/che/api/user/server/jpa/JpaUserDao.java)

- [Workspace DAO](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-workspace/src/main/java/org/eclipse/che/api/workspace/server/spi/WorkspaceDao.java) and an example of its implementation [JpaWorkspaceDao](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-workspace/src/main/java/org/eclipse/che/api/workspace/server/jpa/JpaWorkspaceDao.java)

- [Factory DAO](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-factory/src/main/java/org/eclipse/che/api/factory/server/spi/FactoryDao.java) and an example of its implementation [JpaFactoryDao](https://github.com/eclipse/che/blob/master/wsmaster/che-core-api-factory/src/main/java/org/eclipse/che/api/factory/server/jpa/JpaFactoryDao.java)

Eclipse Che uses [H2](http://www.h2database.com/html/main.html) for single-user builds and PostgreSQL database in a multi-user flavor.
