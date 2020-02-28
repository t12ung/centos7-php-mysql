# Docker LAMP Development Environment for CentOS 7

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Poweredby: docker](https://img.shields.io/badge/docker-v18.09-lightgrey.svg?style=plastic&logo=docker&logoColor=white&labelColor=2496ed)](https://www.docker.com/)
[![Poweredby: CentOS](https://img.shields.io/badge/platform-CentOS_7-lightgrey.svg?style=plastic&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAA3NCSVQICAjb4U/gAAABgFBMVEUMC2empcfunAiOxgxCQYn41Zfn88yJCmqv11T1tzXLz+GqUZWGCGlxcKba5LXt2un5/PLXrc34y38lKIPM5pLF4oOgPIn76cibMoNcaKyczSn1+ui2aqW5vNvnzuHvpSD8vme14nPv2rn37fXW4qzNo8fm4ODeu9XT6KAZGG6xZK6NFnK0rs2IiLXt5uGw3WL5ulpSUZPl8cY5OIOZziK6dLL/9u6i0DjZ2ef////s9tb2pQ/vqSrz5O/13aeuXqr54LOTIXnl1L5jXa388d39z4rct9Oy2FkgH3SUyRnExNnJ55LR74f1xnJWXqLe7rjkyN40M4DC4Xz49/rDhbX92orZ7K6s2jvu1ar658PD6GUQD2rytkh+e7S+YqzZs9D///XwqzD96L/+6s6oTZOeOIasrsdtaLCgzzLb2+i1tdD07fze5r3/zGbr+cS+vtb+897l5e+TzxXq1OXv996j1UJmZpmRxxLG5Ig/Pobuoxna6ajunxCKD20nKHlISY1bgPtFAAAAgHRSTlP///////////////////////////////////////////////////////////////////////////8A/////////////////////////////////////////////////////////////////////////////////////////////90d+1QAAAAJcEhZcwAACvAAAArwAUKsNJgAAAAgdEVYdFNvZnR3YXJlAE1hY3JvbWVkaWEgRmlyZXdvcmtzIE1Yu5EqJAAAAiFJREFUeJyF0v1X0lAYB/BBCoKQjCQICBAivA5irDmZKbES3TDiZWoRGu8ESPEeMWD8624gx5044ve3e+7nPue59z4Q+USg/9YtYjU4yV8Tq0DxiONUrccBgaryedXv3DKwXMXjI11vNFLo9TYYdh27s9msSwKwATPwY2bm2U7k8qNGY0qUNMgkIQEKfLChw3Ezk4pc7iHUxMSWJ5RNCgYG//YuswAIfLFpVUoBZsAUG7sjZgYmiOfipa1r9UiALs4cHJ5tX816UAr7W2UqwUpAD8dxUYx2IpG90/3SVhlBqOMH4GngZjNePfQbdLHYrbXUNSEUhWTVC+A2NTqdDj7AsbPzQmG/lKCUiJDTZH0O3ErTu+di3jRYjCQTrMcNi6nxwCuC7gShNn/eRzjC/v36apYAT4OgWAGemLpeMbKoK0qSadb53SnmbTIjm/cAl5sZAADEq6c3f7AIWuDGHMd9cL6QLW5hqwOeB++DU+1tKkXoHcKv2+32T68f3qFN02BYm97Uf305d4QiaDEvlGhJHoqN0sPamq8JfRaAPLyOnuS5Qk4Cmtqgeuirg4xQITYeh9ZRo1GflgA1pA34KoAGIuDsgnDo5UUpoDNrbBLw94Cz567HdimIZgAUiCYz8x7GR2lUzo2NEuDy1uuydrtSURv+FUOhFhEKh8PE8lTnfnyrVvt+3fJUL9LrM8LkkI8D0tI/6JGrAGmxkKvBUp4Ed8ZO8cQUstPVAAAAAElFTkSuQmCC&logoColor=white&labelColor=131e35)](https://www.centos.org/)
[![Poweredby: Apache](https://img.shields.io/badge/apache-v2.4-lightgrey.svg?style=plastic&logo=apache&logoColor=white&labelColor=D22128)](https://www.apache.org/)
[![Poweredby: MySQL](https://img.shields.io/badge/MySQL-%3E=5.7-lightgrey.svg?style=plastic&logo=mysql&logoColor=white&labelColor=0074a3)](https://www.mysql.com)
[![Poweredby: PHP](https://img.shields.io/badge/php-%3E=7.3-lightgrey.svg?style=plastic&logo=php&logoColor=white&labelColor=8892BF)](http://www.php.net/)

This LAMP stack runs on Docker so you should install that first if you've not already done so. The stack _should_ be compatible with Linux, Windows or MacOS. For windows, although not necessary, you should either install WSL or GitBash to be able to run the `setup.sh` script.

The docker containers are built according to the configuration of the `docker-compose.yml` file, which consists of two containers - web server & database server. `docker-compose` commands ([CLI reference](https://docs.docker.com/compose/reference/overview/)) must be run from the directory where the `yml` file is located as it references the containers by **service name**. Alternatively, you can run the equivalent `docker` command and specify either **container ID or NAME**. The docker images of each are based on _official_ docker images. The customisation of these are as follows:

##### mysql - (mysql:5.7)
- mysqld options via `99-mysql.cnf` file to enable log files
##### webserver - (centos/php-73-centos7)
- Additional package repositories
- Additional packages/php modules installed
  - browscap (Lite)
  - geoip
  - igbinary
  - imagick
  - memcached
  - odbc
  - sqlsrv
  - tidy
  - xdebug
  - xmlrpc

> **TODO:**
> - Detect if development host already added to hosts file(s) and ignore/update
> - Support for configurations using different versions of software stack
> - Add support for initialising database with data from SQL dump files


## Usage
<sub>NOTE: On Windows OS (if you've not done so before), you should run configure the following git setting before checking out the project:</sub>
```shell
git config --global core.autocrlf input
```
It is recommended you checkout this repository for each web project rather than rely on vhost configuration within the stack. Open a shell and change to the directory that will contain all your projects and clone this repo to your machine.

```shell
git clone <repo> <project_name>
```

### Basic Configuration
Change into the directory you checked out the repo to and run:
```shell
./setup.sh
```
You will be prompted a few questions to configure the `.env` and `docker-compose.yml` files.

You are given the option to use the Nginx web server proxy. If you are just running a single web project, then it's easier to run without the proxy. If you are running muliple projects, you can choose not to use the proxy, but you would have to ensure each web server uses different ports when running simultaneously or they will conflict with each other. With Nginx, you just choose different hostnames and don't need to worry about conflicting ports.

If you choose to not enable log files, log is output to docker logs for the container. When running services in foreground, the logs are ouput to the screen (-f follow). When running in detached mode (background process), to see the log you need to run `docker-compose logs`. When enabling service log files, you can access them from the relevant directory that is mapped to `logs` directory of your local machine.

A summary is displayed after the script finishes running to confirm your settings and some information on quickly getting started.

### Build the Container Images
If you are using Nginx Web Proxy, you should start that service first. If you specify the **service names** (space separated) at the end of a `docker-compose` command, it will only apply to those services. Before we copy our website code into our webserver container, it's a good idea to check our LAMP configuration works. Build the containers and try to access the website url as shown in the `setup.sh` summary output -- you should see a phpinfo page.

<table>
<tr><th align=left colspan=2><sub>Build Container</sub></th></tr>
<tr><td><code>docker-compose up --build</code></td><td><sub>build each container if image not created or changed before starting all services</sub></td></tr>
<tr><td><code>docker-compose build</code></td><td><sub>build only</sub></td></tr>
</table>

<table>
<tr><th align=left colspan=2><sub>Stop Container</sub></th></tr>
<tr><td><code>[Control]+[C]</code></td><td><sub>Abort all service(s) running as a foreground process</sub></td></tr>
<tr><td><code>docker-compose stop</code></td><td><sub>Stop all services if running as detached or in foreground from another localhost shell</sub></td></tr>
<tr><td><code>docker-compose down</code></td><td><sub>Stop all services and remove all containers/networks used by the compose file, except external resources</sub></td></tr>
</table>

<table>
<tr><th align=left colspan=2><sub>Start Container</sub></th></tr>
<tr><td><code>docker-compose up</code></td><td><sub>Run all services as foreground process</sub></td></tr>
<tr><td><code>docker-compose up -d</code></td><td><sub>Run all services as background process</sub></td></tr>
<tr><td><code>docker-compose run -d &lt;service_name&gt;</code></td><td><sub>Run a single service as a background process</sub></td></tr>
<tr><td><code>docker-compose restart</code></td><td><sub>Run all services as background process (restart if already running)</sub></td></tr>
</table>

<table>
<tr><th align=left colspan=2><sub>Execute a one-time command inside a Container</sub></th></tr>
<tr><td><code><a href="https://docs.docker.com/engine/reference/commandline/exec/">docker exec</a> &lt;options&gt; &lt;container_id|container_name&gt; &lt;command&gt;</code></td><td><sub>Execute a command - can be interactive (e.g. <code>bash</code>)</sub></td></tr>
<tr><td><code>docker exec -it &lt;container_id|container_name&gt; &lt;bash&gt;</code></td><td><sub>Run an <code>I</code>nteractive bash <code>T</code>erminal</code></sub></td></tr>
</table>

### Running your Website code
The web server's root directory is directly mapped to the `www` directory on your local machine. Any changes you make inside this automatically updates the website.

Copy your website code folder into the `www` directory (or checkout your code as a directory - just as we did to checkout this LAMP stack). Now update `DOCUMENT_ROOT` in the `.env` file - you need to restart the webserver container for the `DOCUMENT_ROOT` change to take effect.

### MySQL Data
Once you've built and initialised your database, the data files are populated and mapped to your local machine in `data/mysql`. Initialisation should not re-occur once the data is populated. If you need to start with a clean database, simply backup or delete the files.

## Advanced Configuration
Within `bin` directory are files relating to a docker image. Inside, the image there is a `root` directory - this is copied to the `root` directory of the docker image. If you make changes to any files in within `root` of your local machine, you need to rebuild the docker container so initialisation copies the new files.

<table>
<tr><td><code>config/php/browscap.ini</code></td><td><sub>Directly mapped to `php.d` location on web server (Scan dir for additional .ini files)</sub></td></tr>
<tr><td><code>config/php/99-php.ini</code></td><td><sub>As above - Additional PHP ini settings that override other settings</sub></td></tr>
<tr><td><code>bin/<service_name>/Dockerfile</code></td><td><sub>Defines the base source of the image and initialisation commands (package installation)</sub></td></tr>
<tr><td><code>bin/mysql/root/tmp/mysql/99-mysql.cnf</code></td><td><sub>mysqld configuration file</sub></td></tr>
<tr><td><code>bin/webserver/root/usr/libexec</code></td><td><sub>Initialisation script to customise the <a href="https://github.com/sclorg/s2i-php-container/blob/master/7.2/Dockerfile">base docker image</a></sub></td></tr>
</table>
