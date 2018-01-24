---
title: "Install on Docker&#58 Bypass CLI"
keywords: docker, installation
tags: [installation, docker]
sidebar: user_sidebar
permalink: docker-native.html
folder: setup
---

## Run the Image  

You can run the Che server directly by launching a Docker image. This approach bypasses the CLI, which has additional utilities to simplify administration and operation. The `eclipse/che-server` Docker image is appropriate for running Che within clusters, orchestrators, or by third party tools with automation.

```shell  
# Run the latest released version of Che
# Replace <LOCAL_PATH> with any host folder
# Che will place backup files there - configurable properties, workspaces, lib, storage
docker run -p 8080:8080 \
           --name che \
           --rm \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0

# To run the nightly version of Che, replace eclipse/che-server:5.0.0-latest with
eclipse/che-server:nightly

# To run a specific tagged version of Che, replace eclipse/che-server:5.0.0-latest with
eclipse/che-server:<version>

# Stop the container running Che
docker stop che

# Restart the container running Che and restart the Che server
docker restart che

# Upgrade to a newer version
docker pull eclipse/che-server:6.0.0-latest
docker restart che
```

Che has started when you see `Server startup in ##### ms`.  After starting, Che is available at `localhost:8080` or a remote IP if Che has been started remotely.

## SELinux

If SELinux is enabled, then run this instead:

```shell  
# Run the latest released version of Che
docker run -p 8080:8080 \
           --name che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data:Z \
           --security-opt label:disable \
           eclipse/che-server:6.0.0
```

## Ports

Tomcat inside the container will bind itself to port 8080 by default. You must map this port to be exposed in your container using `-p 8080:8080`.  If you want to change the port at which your browsers connect, then change the first value, such as `p 9000:8080`.  This will route requests from port 9000 to the internal Tomcat bound to port 8080.  If you want to change the internal port that Tomcat is bound, you must update the port binding and set `CHE_PORT` to the new value.

```text  
docker run -p 9000:9500 \
           --name che \
           -e CHE_PORT=9500 \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0
```

## Configuration

Most important configuration properties are defined as environment variables that you pass into the container. For example, to have Che listen on port 9000:

```shell  
docker run -p:9000:9000 \
           --name che \
           -e CHE_SERVER_ACTION=stop \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0
```

There are many variables that can be set.

| Variable   | Description   | Defaults   
| --- | --- | ---
| `CHE_SERVER_ACTION`   | The command to send to Tomcat. it can be [`run`, `start` , `stop`].   | `run`   
| `CHE_ASSEMBLY`   | The path to a Che assembly that is on your host to be used instead of the assembly packaged within the `che-server` image. If you set this variable, you must also volume mount the same directory to `/home/user/che`   | `/home/user/che`   
| `CHE_IN_VM`   | Set to 'true' if this container is running inside of a VM providing Docker such as boot2docker, Docker for Mac, or Docker for Windows. We auto-detect this for most situations, but it's not always perfect.   | auto-detection   
| `CHE_LOG_LEVEL`   | Logging level of output for Che server. Can be `debug` or `info`.   | `info`   
| `CHE_HOST`   | IP address/hostname Che server will bind to. Used by browsers to contact workspaces. You must set this IP address if you want to bind the Che server to an external IP address that is not the same as Docker's.   | The IP address set to the Docker host. This does cover 99% of situations, but on rare occassions we are not able to discover this IP address and you must provide it.   
| `CHE_DEBUG_SERVER`   | If `true`, then will launch the Che server with JPDA activated so that you a Java debugger can attach to the Che server for debugging plugins, extensions, and core libraries.   | `false`   
| `CHE_DEBUG_SERVER_PORT`   | The port that the JPDA debugger will listen.   | `8000`   
| `CHE_DEBUG_SERVER_SUSPEND`   | If `true`, then activates `JPDA_SUSPEND` flag for Tomcat running the Che server. Used for advanced internal debugging of extensions.   | `false`   
| `CHE_PORT`   | The port the Che server will bind itself to within the Che container.   | `8080`   

You can find list of envs in [che.env](https://github.com/eclipse/che/blob/master/dockerfiles/init/manifests/che.env).

You can create a file with envs you want to pass to che-server:


```shell  
docker run -p:8080:8080 \
           --name che \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           --env-file /home/user/che.env \
           eclipse/che-server:6.0.0
```


## Run Che on Public IP Address

If you want to have remote browser clients connect to the Che server (as opposed to local browser clients) and override the defaults that we detect, set `CHE_IP` to the Docker host IP address that will have requests forwarded to the `che-server` container.

We run an auto-detection algorithm within the che-server container to determine this IP.  If Docker is running on `boot2docker` this is usually the `eth1` interface. If you are running Docker for Windows or Docker for Mac this is usually the `eth0` interface. If you are running Docker natively on Linux, this is the `docker0` interface. If your host that is running Docker has its IP at 10.0.75.4 and you wanted to allow remote clients access to this container then:

```shell  
docker run -p:8080:8080 \
           --name che \
           -e CHE_HOST=10.0.75.4 \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0
```

## Run Che as a Daemon

Pass the `--restart always` parameter to the docker syntax to have the Docker daemon restart the container on any exit event, including when your host is initially booting. You can also run Che in the background with the `-d` option.

```shell  
docker run -p:8080:8080 \
           --name che \
           --restart always \
           -e CHE_HOST=10.0.75.4 \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0
```


## Run With Docker Compose

```yaml  
che:
   image: eclipse/che-server:6.0.0
   port: 8080:8080
   restart: always
   volumes:
     - /var/run/docker.sock:/var/run/docker.sock
     - <LOCAL_PATH>:/data
   container_name: che
```

Save this into a file named `Composefile`. You can then run this with Docker Compose with `docker-compose -f Composefile -d --env-file=che.env`. Environment file should contain one must have env:

```
# $IP is a public IP of your server
CHE_HOST=$IP
```

{% include links.html %}
