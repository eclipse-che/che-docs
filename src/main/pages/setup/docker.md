---
title: "Single-User&#58 Install on Docker"
keywords: docker, installation
tags: [installation, docker]
sidebar: user_sidebar
permalink: docker.html
folder: setup
---

## Pre-Requisites

* Docker 17+ recommended, ideally the [latest Docker version](http://docs.docker.com/engine/installation/). Even though Che may not have any issues with Docker 1.13+, all tests use Docker 17+.

```bash
wget -qO- https://get.docker.com/ | sh
```

* OS: Linux, MacOS, Windows.

<span style="color:red; margin-left:41px;">**IMPORTANT!**</span>

Mac-OS users need to create IP alias: `sudo ifconfig lo0 alias 192.168.65.2`.

Note that IP `192.168.65.2` may differ on some Docker for Mac versions. You can get this IP in your Docer fro Mac app **Preferences > Advanced > Docker subnet**.

* Min 1 CPU, 2GM RAM, 3GB disc space


The default port required to run Che is `8080`. Che performs a preflight check when it boots to verify that the port is available. You can pass `-e CHE_PORT=<port>` in Docker portion of the start command to change the port that Che starts on.

Internal ports are ports within a local network. This is the most common scenario for most users when Che is installed on their local desktop/laptop. External ports are ports outside a local network. An example scenario of this would be a remote Che server on a cloud host provider. With either case ports need to be open and not blocked by firewalls or other applications already using the same ports.

All ports are TCP unless otherwise noted.

|Port >>>>>>>>>>>>>>>>|Service >>>>>>>>>>>>>>>>|Notes|
|---|---|---|
|5000|Keycloak Port|Multi-user only
|8080|Tomcat Port| Che server default port
|8000|Server Debug Port|Users developing Che extensions and custom assemblies would use this debug port to connect a remote debugger to Che server.
|32768-65535|Docker and Che Agents|Users who launch servers in their workspace bind to ephemeral ports in this range. This range can be limited.

## Known Issues

You can search Che's GitHub issues for items labeled `kind/bug` to see [known issues](https://github.com/eclipse/che/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Akind%2Fbug).

There are two known issues where features work on Docker 1.13+, but do not on Docker 1.12:

* SELinux: [https://github.com/eclipse/che/issues/4747](https://github.com/eclipse/che/issues/4747)
* `CHE_DOCKER_ALWAYS__PULL__IMAGE`: [https://github.com/eclipse/che/issues/5503](https://github.com/eclipse/che/issues/5503)

Sometimes Fedora and RHEL/CentOS users will encounter issues with SElinux. Try disabling selinux with `setenforce 0` and check if resolves the issue. If using the latest docker version and/or disabling SElinux does not fix the issue then please file a issue request on the [issues](https://github.com/eclipse/che/issues) page.

## Quick Start

```shell
# Interactive help. This command will fail by default but the CLI will print a prompt on how to proceed
docker run -it eclipse/che start

# Or, full start syntax where <path> is a local directory
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v <path>:/data eclipse/che start

# Example output

$ docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v ~/Documents/che-data1:/data eclipse/che start
WARN: Bound 'eclipse/che' to 'eclipse/che:5.20.1'
INFO: (che cli): 5.20.1 - using docker 17.10.0-ce / native
WARN: Newer version '5.21.0' available
INFO: (che config): Generating che configuration...
INFO: (che config): Customizing docker-compose for running in a container
INFO: (che start): Preflight checks
         mem (1.5 GiB):           [OK]
         disk (100 MB):           [OK]
         port 8080 (http):        [AVAILABLE]
         conn (browser => ws):    [OK]
         conn (server => ws):     [OK]

INFO: (che start): Starting containers...
INFO: (che start): Services booting...
INFO: (che start): Server logs at "docker logs -f che"
INFO: (che start): Booted and reachable
INFO: (che start): Ver: 5.20.1
INFO: (che start): Use: http://172.19.20.180:8080
INFO: (che start): API: http://172.19.20.180:8080/swagger
````

The Che CLI - a Docker image - manages the other Docker images and supporting utilities that Che uses during its configuration or operations phases. Che installation with the CLI is a recommended installation method, however it is possible to run `che-server` image directly. See: [Run Che-Server directly][#run-without-cli].


## Versions

Each version of Che is available as a Docker image tagged with a label that matches the version, such as `eclipse/che:6.0.0`. You can see all versions available by running `docker run eclipse/che version` or by [browsing DockerHub](https://hub.docker.com/r/eclipse/che/tags/).

We maintain "redirection" labels which reference special versions of Che:

| Variable | Description |
|----------|-------------|
| `latest` | The most recent stable release. |
| `6.0.0-latest` | The most recent stable release on the 6.x branch. |
| `nightly` | The nightly build. |

The software referenced by these labels can change over time. Since Docker will cache images locally, the `eclipse/che:<version>` image that you are running locally may not be current with the one cached on DockerHub. Additionally, the `eclipse/che:<version>` image that you are running references a manifest of Docker images that Che depends upon, which can also change if you are using these special redirection tags.

In the case of 'latest' images, when you initialize an installation using the CLI, we encode a `/instance/che.ver` file with the numbered version that latest references. If you begin using a CLI version that mismatches what was installed, you will be presented with an error.

To avoid issues that can appear from using 'nightly' or 'latest' redirections, you may:

1. Verify that you have the most recent version with `docker pull eclipse/che:<version>`.
2. When running the CLI, commands that use other Docker images have an optional `--pull` and `--force` command line option [which will instruct the CLI to check DockerHub](https://hub.docker.com/r/eclipse/che/) for a newer version and pull it down. Using these flags will slow down performance, but ensures that your local cache is current.

If you are running Che using a tagged version that is a not a redirection label, such as `6.0.0`, then these caching issues will not happen, as the software installed is tagged and specific to that particular version, never changing over time.

## Volume Mounts

We use volume mounts to configure certain parts of Che. The presence or absence of certain volume mounts will trigger certain behaviors in the system. For example, you can volume mount a Che source git repository with `:/repo` to use Che source code instead of the binaries and configuration that is shipped with our Docker images.

At a minimum, you must volume mount a local path to `:/data`, which will be the location that Che installs its configuration, user data, version and log information. Che also leaves behind a `cli.log` file in this location to debug any odd behaviors while running the system. In this folder we also create a `che.env` file which contains all of the admin configuration that you can set or override in a single location.

You can also use volume mounts to override the location of where your user or backup data is stored. By default, these folders will be created as sub-folders of the location that you mount to `:/data`. However, if you do not want your `/instance`, and `/backup` folder to be children, you can set them individually with separate overrides.

```
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock
                    -v <local-path>:/data
                    -v <a-different-path>:/data/instance
                    -v <another-path>:/data/backup
                       eclipse/che:<version> [COMMAND]    
```

| Local Location   | Container Location   | Usage   
| --- | --- | ---
| `/var/run/docker.sock`   | `/var/run/docker.sock`   | This is how Che gets access to Docker daemon. This instructs the container to use your local Docker daemon when Che wants to create its own containers.   
| `/<your-path>/lib`   | `/data/lib`   | Inside the container, we make a copy of important libraries that your workspaces will need and place them into `/lib`. When Che creates a workspace container, that container will be using your local Docker daemon and the Che workspace will look for these libraries in your local `/lib`. This is a tactic we use to get files from inside the container out onto your local host.   
| `/<your-path>/workspaces`   | `/data/workspaces`   | The location of your workspace and project files.   
| `/<your-path>/storage`   | `/data/storage`   | The location where Che stores the meta information that describes the various workspaces, projects and user preferences.  


## Hosting

If you are hosting Che at a cloud service like DigitalOcean, AWS or Scaleways `CHE_HOST` must be set to the server public IP address or its DNS.

We will attempt to auto-set `CHE_HOST` by running an internal utility `docker run --net=host eclipse/che-ip:nightly`. This approach is not fool-proof. This utility is usually accurate on desktops, but usually fails on hosted servers. You can explicitly set this value to the IP address of your server:

```
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock
                    -v <local-path>:/data
                    -e CHE_HOST=<your-ip-or-host>
                       eclipse/che:<version> [COMMAND]
```

## Run on Different Port

Either set `CHE_PORT=$your_port` in [che.env](docker-config.html#saving-configuration-in-version-control) or pass it as env in your docker run syntax: `-e CHE_PORT=$your_port`.

## Run As User

On Linux or Mac, you can run Eclipse Che container with a different user identity. The default is to run the Che container as root. You can  pass `--user uid:gid` or `-e CHE_USER=uid:gid` as a `docker run` parameter before the `eclipse/che` Docker image. The CLI will start the `eclipse/che-server` image with the same `uid:gid` combination along with mounting `/etc/group` and `etc/passwd`. When Che is run as a custom user, all files written from within the Che server to the host (such as `che.env` or `cli.log` will be written to disk with the custom user as the owner of the files. This feature is not available on Windows.


## Offline Installation

We support offline (disconnected from the Internet) installation and operation. This is helpful for restricted environments, regulated datacenters, or offshore installations. The offline installation downloads the CLI, core system images, and any stack images while you are within a network DMZ with DockerHub access. You can then move those files to a secure environment and start Che.

1. Save Che Images

While connected to the Internet, download Che Docker images:

```shell
docker run <docker-goodness> eclipse/che:<version> offline
```

The CLI will download images and save them to `/backup/*.tar` with each image saved as its own file. You can save these files to a different location by volume mounting a local folder to `:/data/backup`. The version tag of the CLI Docker image will be used to determine which versions of dependent images to download. There is about 1GB of data that will be saved.

The default execution will download none of the optional stack images, which are needed to launch workspaces of a particular type. There are a few dozen stacks for different programming languages and some of them are over 1GB in size. It is unlikely that your users will need all of the stacks, so you do not need to download all of them. You can get a list of available stack images by running `eclipse/che offline --list`. You can download a specific stack by running `eclipse/che offline --image:<image-name>` and the `--image` flag can be repeatedly used on a single command line.

2. Start Che In Offline Mode

Place the TAR files into a folder in the offline computer. If the files are in placed in a folder named `/tmp/offline`, you can run Che in offline mode with:

```shell
# Load the CLI
docker load < /tmp/offline/eclipse_che:<version>.tar

# Start Che in offline mode
docker run <other-properties> -v /tmp/offline:/data/backup eclipse/che:<version> start --offline
```

The `--offline` parameter instructs the Che CLI to load all of the TAR files located in the folder mounted to `/data/backup`. These images will then be used instead of routing out to the Internet to check for DockerHub. The preboot sequence takes place before any CLI functions make use of Docker. The `eclipse/che start`, `eclipse/che download`, and `eclipse/che init` commands support `--offline` mode which triggers this preboot sequence.


## Upgrade

Upgrading Che is done by downloading a `eclipse/che-cli:<version>` that is newer than the version you currently have installed. You can run `eclipse/che-cli version` to see the list of available versions that you can upgrade to.

For example, if you have 6.0.0 installed and want to upgrade to 6.0.1, then:

```
# Get the new version of Che
docker pull eclipse/che-cli:6.0.0

# You now have two eclipse/che-cli images (one for each version)
# Perform an upgrade - use the new image to upgrade old installation
docker run <volume-mounts> eclipse/che-cli:6.0.1 upgrade
```

The upgrade command has numerous checks to prevent you from upgrading Che if the new image and the old version are not compatible. In order for the upgrade procedure to advance, the CLI image must be newer that the version in `/instance/che.ver`.

The upgrade process:

1. Performs a version compatibility check
2. Downloads new Docker images that are needed to run the new version of Che
3. Stops Che if it is currently running
4. Triggers a maintenance window
5. Backs up your installation
6. Initializes the new version
7. Starts Che
8. Important! If `CHE_PREDEFINED_STACKS_RELOAD__ON__START` is set to false, stacks packaged into new binaries will not be saved into a database.

## Backup

You can run `che backup` to create a copy of the relevant configuration information, user data, projects, and workspaces. We do not save workspace snapshots as part of a routine backup exercise. You can run `che restore` to recover Che from a particular backup snapshot. The backup is saved as a TAR file that you can keep in your records. You can then use `che restore` to recover your user data and configuration.

## Configuration

Che CLI allows a wide range of config changes to setup port, hostname, oAuth, Docker, git, and solve networking issues. See: [Che configuration on Docker][docker-config].

## Run Without CLI

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

**SELinux**

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

**Ports**

Tomcat inside the container will bind itself to port 8080 by default. You must map this port to be exposed in your container using `-p 8080:8080`.  If you want to change the port at which your browsers connect, then change the first value, such as `p 9000:8080`.  This will route requests from port 9000 to the internal Tomcat bound to port 8080.  If you want to change the internal port that Tomcat is bound, you must update the port binding and set `CHE_PORT` to the new value.

```text  
docker run -p 9000:9500 \
           --name che \
           -e CHE_PORT=9500 \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v <LOCAL_PATH>:/data \
           eclipse/che-server:6.0.0
```

**Configuration**

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


**Run Che on Public IP Address**

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

**Run Che as a Daemon**

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


**Run With Docker Compose**

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
