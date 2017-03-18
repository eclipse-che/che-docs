---
tags: [ "eclipse" , "che" ]
title: CLI Reference
excerpt: ""
layout: artik
permalink: /:categories/setup-cli/
---
{% include base.html %}

The Docker image which runs ARTIK is the ARTIK CLI. It has various commands for running ARTIK and also for allowing your end users to interact with their workspaces on the command line.

```
USAGE:
  docker run -it --rm <DOCKER_PARAMETERS> codenvy/artik-cli:<version> [COMMAND]

MANDATORY DOCKER PARAMETERS:
  -v <LOCAL_PATH>:/data                Where user, instance, and log data saved

OPTIONAL DOCKER PARAMETERS:
  -e CHE_HOST=<YOUR_HOST>              IP address or hostname where che will serve its users
  -e CHE_PORT=<YOUR_PORT>              Port where artik will bind itself to
  -v <LOCAL_PATH>:/data/instance       Where instance, user, log data will be saved
  -v <LOCAL_PATH>:/data/backup         Where backup files will be saved
  -v <LOCAL_PATH>:/repo                artik git repo - uses local binaries
  -v <LOCAL_PATH>:/sync                Where remote ws files will be copied with sync command
  -v <LOCAL_PATH>:/unison              Where unison profile for optimizing sync command resides

COMMANDS:
  action <action-name>                 Start action on artik instance
  backup                               Backups artik configuration and data to /data/backup volume mount
  config                               Generates a artik config from vars; run on any start / restart
  destroy                              Stops services, and deletes artik instance data
  download                             Pulls Docker images for the current artik version
  help                                 This message
  info                                 Displays info about artik and the CLI
  init                                 Initializes a directory with a artik install
  offline                              Saves artik Docker images into TAR files for offline install
  restart                              Restart artik services
  restore                              Restores artik configuration and data from /data/backup mount
  rmi                                  Removes the Docker images for <version>, forcing a repull
  ssh <wksp-name> [machine-name]       SSH to a workspace if SSH agent enabled
  start                                Starts artik services
  stop                                 Stops artik services
  sync <wksp-name>                     Synchronize workspace with local directory mounted to :/sync
  test <test-name>                     Start test on artik instance
  upgrade                              Upgrades artik from one version to another with migrations and backups
  version                              Installed version and upgrade paths

GLOBAL COMMAND OPTIONS:
  --fast                               Skips networking and version checks (saves 5 secs during bootstrap)
  --debug                              Enable debugging of artik server
```

The CLI will hide most error conditions from standard out. Internal stack traces and error output is redirected to `cli.log`, which is saved in the host folder where `:/data` is mounted.

### action
Executes some actions on the ARTIK IDE server or on a workspace running inside ARTIK.
For example to list all workspaces on ARTIK, the following command can be used `action list-workspaces`.
To execute a command on a workspace `action execute-command <workspace-name> <action>` where action can be any bash command.

### backup
TARS your `/instance` into files and places them into `/backup`. These files are restoration-ready.

### config
Generates an ARTIK instance configuration thta is placed in `/instance`. This command uses puppet to generate Docker Compose configuration files to run ARTIK and its associated server. ARTIK's server configuration is generated as a che.properties file that is volume mounted into the ARTIK server when it boots. This command is executed on every `start` or `restart`.

If you are using a `codenvy/artik-cli:<version>` image and it does not match the version that is in `/instance/artik.ver`, then the configuration will abort to prevent you from running a configuration for a different version than what is currently installed.

This command respects `--no-force`, `--pull`, `--force`, and `--offline`.

### destroy
Deletes `/docs`, `artik.env` and `/instance`, including destroying all user workspaces, projects, data, and user database. If you pass `--quiet` then the confirmation warning will be skipped. Passing `--cli` will also destroy the `cli.log`. By default this is left behind for traceability.

### download
Used to download Docker images that will be stored in your Docker images repository. This command downloads images that are used by the CLI as utilities, for ARTIK to do initialization and configuration, and for the runtime images that ARTIK needs when it starts.  This command respects `--offline`, `--pull`, `--force`, and `--no-force` (default).  This command is invoked by `artik init`, `artik config`, and `artik start`.

`download` is invoked by `artik init` before initialization to download images for the version specified by `codenvy/artik-cli:<version>`.

### info
Displays system state and debugging information. `--network` runs a test to take your `CHE_HOST` value to test for networking connectivity simulating browser > ARTIK and ARTIK > workspace connectivity.

### init
Initializes an empty directory with an ARTIK configuration and instance folder where user data and runtime configuration will be stored. You must provide a `<path>:/data` volume mount, then ARTIK creates a `instance` and `backup` subfolder of `<path>`. You can optionally override the location of `instance` by volume mounting an additional local folder to `/data/instance`. You can optionally override the location of where backups are stored by volume mounting an additional local folder to `/data/backup`.  After initialization, an `artik.env` file is placed into the root of the path that you mounted to `/data`.

These variables can be set in your local environment shell before running and they will be respected during initialization:

| Variable | Description |
|----------|-------------|
| `CHE_HOST` | The IP address or DNS name of the ARTIK service. We use `eclipse/che-ip` to attempt discovery if not set. |
| `CHE_PORT` | The port the ARTIK server will run on and expose in its container for your clients to connect to. |

ARTIK depends upon Docker images. We use Docker images to:

1. Provide cross-platform utilites within the CLI. For example, in scenarios where we need to perform a `curl` operation, we use a small Docker image to perform this function. We do this as a precaution as many operating systems (like Windows) do not have curl installed.
2. Look up the master version and upgrade manifest, which is saved within the CLI docker image in the /version subfolder.
3. Perform initialization and configuration of ARTIK such as with `codenvy/artik-init`. This image contains templates to be installed onto your computer used by the CLI to configure Che for your specific OS.

You can control how ARTIK downloads these images with command line options. All image downloads are performed with `docker pull`.

| Mode >>>>>>>>>>>> | Description |
|------|-------------|
| `--no-force` | Default behavior. Will download an image if not found locally. A local check of the image will see if an image of a matching name is in your local registry and then skip the pull if it is found. This mode does not check DockerHub for a newer version of the same image. |
| `--pull` | Will always perform a `docker pull` when an image is requested. If there is a newer version of the same tagged image at DockerHub, it will pull it, or use the one in local cache. This keeps your images up to date, but execution is slower. |
| `--force` | Performs a forced removal of the local image using `docker rmi` and then pulls it again (anew) from DockerHub. You can use this as a way to clean your local cache and ensure that all images are new. |
| `--offline` | Loads Docker images from `backup/*.tar` folder during a pre-boot mode of the CLI. Used if you are performing an installation or start while disconnected from the Internet. |

You can reinstall ARTIK on a folder that is already initialized and preserve your `artik.env` values by passing the `--reinit` flag.

### offline
Saves all of the Docker images that ARTIK requires into `/backup/*.tar` files. Each image is saved as its own file. If the `backup` folder is available on a machine that is disconnected from the Internet and you start ARTIK with `--offline`, the CLI pre-boot sequence will load all of the Docker images in the `/backup/` folder.

`--list` option will list all of the core images and optional stack images that can be downloaded. The core system images and the CLI will always be saved, if an existing TAR file is not found. `--image:<image-name>` will download a single stack image and can be used multiple times on the command line. You can use `--all-stacks` or `--no-stacks` to download all or none of the optional stack images.

### restart
Performs a `stop` followed by a `start`, respecting `--pull`, `--force`, and `--offline`.

### restore
Restores `/instance` to its previous state. You do not need to worry about having the right Docker images. The normal start / stop / restart cycle ensures that the proper Docker images are available or downloaded, if not found.

This command will destroy your existing `/instance` folder, so use with caution, or set these values to different folders when performing a restore.

### rmi
Deletes the Docker images from the local registry that ARTIK has downloaded for this version.

### ssh
Connects the current terminal where the command is started to the terminal of a machine of the workspace. If no machine is specified in the command, it will connect to the default machine which is the dev machine.
The syntax is `ssh <workspace-name> [machine-name]`
The ssh connection will work only if there is a workspace ssh key setup. A default ssh key is automatically generated when a workspace is created.

### start
Starts ARTIK and its services using `docker-compose`. If the system cannot find a valid configuration it will perform an `init`. Every `start` and `restart` will run a `config` to generate a new configuration set using the latest configuration. The starting sequence will perform pre-flight testing to see if any ports required by ARTIK are currently used by other services and post-flight checks to verify access to key APIs.  

### stop
The default stop is a graceful stop where each workspace is stopped and confirmed shutdown before stopping system services. If workspaces are configured to snap on stop, then all snaps will be completed before system service shutdown begins. You can ignore workspace stop behavior and shut down only system services with --force flag. 

### test
Performs some tests on your local instance of ARTIK. It can for example check the ability to create a workspace, start the workspace by using a custom Workspace runtime and then use it.
The list of all the tests available can be obtained by providing only `test` command.

### upgrade
Manages the sequence of upgrading ARTIK from one version to another. Run the Docker syntax with `codenvy/artik-cli version` to get a list of available versions that you can upgrade to.

Upgrading ARTIK is done by using a `codenvy/artik-cli:<version>` that is newer than the version you currently have installed. For example, if you have 1.3.1 installed and want to upgrade to 1.4.0, then:

```
# Get the new version of ARTIK
docker pull codenvy/artik-cli:1.4.0

# You now have two codenvy/artik-cli images (one for each version)
# Perform an upgrade - use the new image to upgrade old installation
docker run <volume-mounts> codenvy/artik-cli:1.4.0 upgrade
```

The upgrade command has numerous checks to prevent you from upgrading ARTIK if the new image and the old version are not compatiable. In order for the upgrade procedure to proceed, the CLI image must be newer than the value of '/instance/artik.ver'.

The upgrade process: a) performs a version compatibility check, b) downloads new Docker images that are needed to run the new version of ARTIK, c) stops ARTIK if it is currently running triggering a maintenance window, d) backs up your installation, e) initializes the new version, and f) starts ARTIK.

Run the Docker syntax with `codenvy/artik-cli version` to get a list of available versions that you can upgrade to.

`--skip-backup` option allow to skip [backup](https://github.com/codenvy/che-docs/blob/master/src/main/_docs/setup/setup-cli.md#backup) during update, that could be useful to speed up upgrade because [backup](https://github.com/codenvy/che-docs/blob/master/src/main/_docs/setup/setup-cli.md#backup) can be very expensive operation if `/instace` folder is really big due to many user worksapces and projects.

###### version
Provides information on the current version and the available versions that are hosted in ARTIK's repositories. `artik-cli upgrade` enforces upgrade sequences and will prevent you from upgrading one version to another version where data migrations cannot be guaranteed.
