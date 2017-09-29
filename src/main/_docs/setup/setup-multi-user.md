---
tags: [ "eclipse" , "che" ]
title: Multi-User Setup
excerpt: ""
layout: docs
permalink: /:categories/getting-started/
---
{% include base.html %}

# Start Multi-User Che

```docker run -it -e CHE_MULTIUSER=true -e CHE_HOST=${EXTERNAL_IP} -e CHE_KEYCLOAK_AUTH-SERVER-URL=http://${EXTERNAL_IP}:5050/auth -v /var/run/docker.sock:/var/run/docker.sock -v ~/.che-multiuser:/data eclipse/che start
```

`${EXTERNAL_IP}` should be a public IP accessible for all users who will reach a running instance of Che server. You may drop `CHE_HOST` and `CHE_KEYCLOAK_AUTH-SERVER-URL` envs if you are running Che locally and will access it from within the same network. In this case, there are some auto detection and defaults (like `eth0` and `docker0` IPs).

# What's Under the Hood

With `CHE_MULTIUSER=true` Che CLI is instructed to generate a special composefile that will be executed to produce config and run:

* KeyCloak container with pre-configured realm and clients
* PostgreSQL container that will store KeyCloak and Che data
* Che server container with a special build of multi-user Che assembly
