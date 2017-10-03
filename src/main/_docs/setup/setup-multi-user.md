---
tags: [ "eclipse" , "che", "multi-user" ]
title: Multi-User Installation
excerpt: ""
layout: docs
permalink: /:categories/multi-user/
---
{% include base.html %}

# Start Multi-User Che

Use the following syntax to start Che multi-user assembly:

`
docker run -it -e CHE_MULTIUSER=true -e CHE_HOST=${EXTERNAL_IP} -e CHE_KEYCLOAK_AUTH-SERVER-URL=http://${EXTERNAL_IP}:5050/auth -v /var/run/docker.sock:/var/run/docker.sock -v ~/.che-multiuser:/data eclipse/che start
`

`${EXTERNAL_IP}` should be a public IP accessible for all users who will reach a running instance of Che server. You may drop `CHE_HOST` and `CHE_KEYCLOAK_AUTH-SERVER-URL` envs if you are running Che locally and will access it from within the same network. In this case, there are some auto detection and defaults (like `eth0` and `docker0` IPs).

If the abovementioned environment variables are not provided, Che CLI will attempt to auto-detect your server IP. However, it is possible that such auto-detection may produce erroneous results, especially in case of a complex network setup.

# What's Under the Hood

With `CHE_MULTIUSER=true` Che CLI is instructed to generate a special composefile that will be executed to produce config and run:

* KeyCloak container with pre-configured realm and clients
* PostgreSQL container that will store KeyCloak and Che data
* Che server container with a special build of multi-user Che assembly

# Communication Between Containers

## Che Server - KeyCloak

KeyCloak server URL is passed as environment variable to CLI -  `CHE_KEYCLOAK_AUTH-SERVER-URL`. A new installation of Che will bring own KeyCloak server running in a Docker container which is properly configured to communicate with Che server.

## Che Server - PostgreSQL

Che server uses the below defaults to connect to a DB to store info related to users, user preferences and workspaces:

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

Hostname `postgres` will be resolved to PostgreSQL container IP if Che is launched with CLI (powered by Docker Compose). User profile information is directly retrieved from KeyCloak database.


## KeyCloak PostgreSQL

Database URL, port, db name, user and password are defined as environment variables in KeyCloak container. Defaults are:

```
POSTGRES_PORT_5432_TCP_ADDR=postgres
POSTGRES_PORT_5432_TCP_PORT=5432
POSTGRES_DATABASE=keycloak
POSTGRES_USER=keycloak
POSTGRES_PASSWORD=keycloak
```

`postgres` will be resolved to PostgreSQL container IP if Che is launched with CLI (powered by Docker Compose)


# Using Existing KeyCloak and PostgreSQL DB

It is possible to use an existing Keycloak server and PostgreSQL database. To connect to an existing KC instance make sure the following environment variables have correct values:


```
CHE_KEYCLOAK_AUTH__SERVER__URL=http://172.17.0.1:5050/auth
CHE_KEYCLOAK_REALM=che
CHE_KEYCLOAK_CLIENT__ID=che-public
```

You can either create a new realm and a public client or use existing ones. A few things to keep in mind when creating or re-using realms and clients:

* it should be a public client
* `redirectUris` should be `${CHE_HOST}/*`. If no `redirectUris` provided or the one used is not in the list of `redirectUris`, KeyCloak will display an error.
* webOrigins should be `${CHE_HOST}`. If no `webOrigins` provided, KC script won't be injected into a page because of CORS error.
