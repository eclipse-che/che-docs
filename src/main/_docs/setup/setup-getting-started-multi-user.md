---
tags: [ "eclipse" , "che", "multi-user" ]
title: Multi-User Installation
excerpt: ""
layout: docs
permalink: /:categories/multi-user/
---
{% include base.html %}

# Start Multi-User Che

Elcipse Che is now available in single-user and multi-user assemblies. The multi-user assembly uses Keycloak for user authentication and is ideal for teams and collaboration. The single-user Che is suited to personal desktop use.

Use the following syntax to start Che's multi-user assembly:

`
docker run -it -e CHE_MULTIUSER=true -e CHE_HOST=${EXTERNAL_IP} -v /var/run/docker.sock:/var/run/docker.sock -v ~/.che-multiuser:/data eclipse/che start
`
`~/.che-multiuser` is any local path. This is where Che data and config will be stored.

`${EXTERNAL_IP}` should be a public IP accessible to all users who will use the Che instance. You may drop `CHE_HOST` env if you are running Che locally and will access it from within the same network. In this case, Che CLI will attempt to auto-detect your server IP. However, auto-detection may produce erroneous results, especially in case of a complex network setup. If you run Che as a cloud server, i.e. accessible for external users we recommend explicitly providing an external IP for `CHE_HOST`.

# What's Under the Hood

With `CHE_MULTIUSER=true` Che's CLI is instructed to generate a special Docker Composefile that will be executed to produce config and run:

* KeyCloak container with pre-configured realm and clients
* PostgreSQL container that will store KeyCloak and Che data
* Che server container with a special build of multi-user Che assembly

# Communication Between Containers

## Che Server <> KeyCloak

KeyCloak server URL is retrieved from the `CHE_KEYCLOAK_AUTH-SERVER-URL` environment variable. A new installation of Che will use its own KeyCloak server running in a Docker container pre-configured to communicate with Che server. Realm and client are mandatory environment variables. By default KeyCloak environment variables are:

```
CHE_KEYCLOAK_AUTH__SERVER__URL=http://${CHE_HOST}:5050/auth
CHE_KEYCLOAK_REALM=che
CHE_KEYCLOAK_CLIENT__ID=che-public
```

You can also use your own KeyCloak server. Either create a new realm and a public client or use the existing values (in this case, re-configure the values in `che.env` to match yours). A few things to keep in mind when creating or re-using realms and clients:

* It must be a public client
* `redirectUris` should be `${CHE_HOST}/*`. If no `redirectUris` are provided or the one used is not in the list of `redirectUris`, KeyCloak will display an error.
* `webOrigins` should be `${CHE_HOST}`. If no `webOrigins` provided, KeyCloak script won't be injected into a page because of CORS error.


## Che Server <> PostgreSQL

Che server uses the below defaults to connect to PostgreSQL to store info related to users, user preferences and workspaces:

```
CHE_JDBC_USERNAME=pgche
CHE_JDBC_PASSWORD=pgchepassword
CHE_JDBC_DATABASE=dbche
CHE_JDBC_URL=jdbc:postgresql://postgres:5432/dbche
CHE_JDBC_DRIVER__CLASS__NAME=org.postgresql.Driver
CHE_JDBC_MAX__TOTAL=20
CHE_JDBC_MAX__IDLE=10
CHE_JDBC_MAX__WAIT__MILLIS=-1
```

Hostname `postgres` will be resolved to PostgreSQL container IP if Che is launched with CLI (powered by Docker Compose). User profile information is directly retrieved from KeyCloak database. You can use own postgreSQL database. Che currently uses version 9.6.


## KeyCloak <> PostgreSQL

Database URL, port, database name, user and password are defined as environment variables in KeyCloak container. Defaults are:

```
POSTGRES_PORT_5432_TCP_ADDR=postgres
POSTGRES_PORT_5432_TCP_PORT=5432
POSTGRES_DATABASE=keycloak
POSTGRES_USER=keycloak
POSTGRES_PASSWORD=keycloak
```

`postgres` will be resolved to PostgreSQL container IP if Che is launched with CLI (powered by Docker Compose).
