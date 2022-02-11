# docker-jmeter-vnc-remote
Docker image setup jmeter cluster lên docker-swarm hoặc k8s, remote qua VNC/browser để chạy test plan
## Pull image
docker pull mkbyme/docker-jmeter-vnc-remote:latest

# Docker container images with "headless" VNC session

**Base on image https://hub.docker.com/r/consol/ubuntu-xfce-vnc**

[**Github source**](https://github.com/mkbyme/docker-jmeter-vnc-remote)

This repository contains a collection of Docker images with headless VNC environments.

Each Docker image is installed with the following components:

* Desktop environment [**Xfce4**](http://www.xfce.org)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client (default http port `6901`), default password: 12345678@Abc
* Browsers:
  * Mozilla Firefox
  * Chromium
* Jmeter 5.4.3
  

## Build Status

## Current provided OS & UI sessions:

* `mkbyme/docker-jmeter-vnc-remote`: __Ubuntu with `Xfce4` UI session__

  [![](https://images.microbadger.com/badges/version/consol/ubuntu-xfce-vnc.svg)](https://hub.docker.com/r/consol/ubuntu-xfce-vnc/) [![](https://images.microbadger.com/badges/image/consol/ubuntu-xfce-vnc.svg)](http://microbadger.com/images/consol/ubuntu-xfce-vnc)

## Kubernetes

It's also possible to run the images in container orchestration platforms like [Kubernetes](https://kubernetes.io). For more information how to deploy containers in the cluster, take a look at:

* [Kubernetes usage of "headless" VNC Docker images](./kubernetes/README.md)

## Usage
Usage is **similar** for all provided images, e.g. for `mkbyme/docker-jmeter-vnc-remote`:

- Print out help page:

      docker run mkbyme/docker-jmeter-vnc-remote --help

- Run command with mapping to local port `5901` (vnc protocol) and `6901` (vnc web access):

      docker run -d -p 5901:5901 -p 6901:6901 mkbyme/docker-jmeter-vnc-remote
  
- Change the default user and group within a container to your own with adding `--user $(id -u):$(id -g)`:

      docker run -d -p 5901:5901 -p 6901:6901 --user $(id -u):$(id -g) mkbyme/docker-jmeter-vnc-remote

- If you want to get into the container use interactive mode `-it` and `bash`
      
      docker run -it -p 5901:5901 -p 6901:6901 mkbyme/docker-jmeter-vnc-remote bash

- Build an image from scratch:

      docker build -t mkbyme/docker-jmeter-vnc-remote centos-xfce-vnc

# Connect & Control
If the container is started like mentioned above, connect via one of these options:

* connect via __VNC viewer `localhost:5901`__, default password: `12345678@Abc`
* connect via __noVNC HTML5 full client__: [`http://localhost:6901/vnc.html`](http://localhost:6901/vnc.html), default password: `12345678@Abc` 
* connect via __noVNC HTML5 lite client__: [`http://localhost:6901/?password=12345678@Abc`](http://localhost:6901/?password=12345678@Abc) 


## Hints

### 1) Extend a Image with your own software
Since version `1.1.0` all images run as non-root user per default, so if you want to extend the image and install software, you have to switch back to the `root` user:

```bash
## Custom Dockerfile
FROM mkbyme/docker-jmeter-vnc-remote
ENV REFRESHED_AT 2021-12-22

# Switch to root user to install additional software
USER 0

## Install a gedit
RUN apt install -y gedit

## switch back to default user
USER 1000
```

### 2) Change User of running Sakuli Container

Per default, since version `1.3.0` all container processes will be executed with user id `1000`. You can change the user id as follows: 

#### 2.1) Using root (user id `0`)
Add the `--user` flag to your docker run command:

    docker run -it --user 0 -p 6911:6901 mkbyme/docker-jmeter-vnc-remote

#### 2.2) Using user and group id of host system
Add the `--user` flag to your docker run command:

    docker run -it -p 6911:6901 --user $(id -u):$(id -g) mkbyme/docker-jmeter-vnc-remote

### 3) Override VNC environment variables
The following VNC environment variables can be overwritten at the `docker run` phase to customize your desktop environment inside the container:
* `VNC_COL_DEPTH`, default: `24`
* `VNC_RESOLUTION`, default: `1280x1024`
* `VNC_PW`, default: `my-pw`

#### 3.1) Example: Override the VNC password
Simply overwrite the value of the environment variable `VNC_PW`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_PW=my-pw mkbyme/docker-jmeter-vnc-remote

#### 3.2) Example: Override the VNC resolution
Simply overwrite the value of the environment variable `VNC_RESOLUTION`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_RESOLUTION=800x600 mkbyme/docker-jmeter-vnc-remote
    
### 4) View only VNC
Since version `1.2.0` it's possible to prevent unwanted control via VNC. Therefore you can set the environment variable `VNC_VIEW_ONLY=true`. If set, the startup script will create a random password for the control connection and use the value of `VNC_PW` for view only connection over the VNC connection.

     docker run -it -p 5901:5901 -p 6901:6901 -e VNC_VIEW_ONLY=true mkbyme/docker-jmeter-vnc-remote

### 5) Known Issues

#### 5.1) Chromium crashes with high VNC_RESOLUTION ([#53](https://github.com/ConSol/docker-headless-vnc-container/issues/53))
If you open some graphic/work intensive websites in the Docker container (especially with high resolutions e.g. `1920x1080`) it can happen that Chromium crashes without any specific reason. The problem there is the too small `/dev/shm` size in the container. Currently there is no other way, as define this size on startup via `--shm-size` option, see [#53 - Solution](https://github.com/ConSol/docker-headless-vnc-container/issues/53#issuecomment-347265977):

    docker run --shm-size=256m -it -p 6901:6901 -e VNC_RESOLUTION=1920x1080 mkbyme/docker-jmeter-vnc-remote chromium-browser http://map.norsecorp.com/
  
Thx @raghavkarol for the hint! 

## How to release
See **[how-to-release.md](./how-to-release.md)**

## Contributors

## Changelog
