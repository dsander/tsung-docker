tsung-docker
============
Docker image to run Tsung distributed load testing tool, intended to be used with Docker Swarm.

This image is based on [ddragosd/tsung-docker](https://github.com/ddragosd/tsung-docker), updated to Tsung 1.6 and intended to be used with Docker Swarm instead of Mesos.

### Usage

This Docker container is designed to execute `Tsung` in 3 modes: `SINGLE`,  `MASTER` and `SLAVE`.

#### Single Mode
Use this single mode to test on the local box, with a single Tsung agent:

```
docker run \
   -e TSUNG_CONFIG=/usr/local/tsung/mytest.xml \
   -v /local/tests:/usr/local/tsung dsander/tsung:latest \
   -r \"ssh -p 22\" start
```

In this mode you can use a single Tsung client
```<client host="localhost" cpu="1" use_controller_vm="true"> </client>```
Note the `-r` flag setting `ssh` port to `22`. This is needed as the SSH runs on port `22` inside the docker container.
In a `MASTER` / `SLAVE` scenarios, we'll have this port mapped to `21` as a convention.

#### Master/Slave Mode on Swarm

* Configure a Swarm cluster with [multi-host networking](https://docs.docker.com/engine/userguide/networking/get-started-overlay/), and three nodes: `bench-master`, `bench-agent-1` and `bench-agent-2`
* Copy your `tsung.yml` to `bench-master`: `docker-machine scp tsung.yml bench-master:/root/tsung.yml`
* Use the example `docker-compose.yml` and start tsung: `docker-compose up`


```yaml
version: '2'

services:
  master:
    image: dsander/tsung
    container_name: tsung_master
    volumes:
      - "/root/:/usr/local/tsung"
    ports:
      - "8091:8091"
    command:
      "start"
    environment:
      - "TSUNG_CONFIG=/usr/local/tsung/tsung.xml"
      - "constraint:node==bench-master"
    networks:
      - tsung
    depends_on:
      - worker_1
      - worker_2

  worker_1:
    image: dsander/tsung
    container_name: tsung_worker_1
    environment:
        - "SLAVE=true"
        - "constraint:node==bench-agent-1"
    networks:
      - tsung
  worker_2:
    image: dsander/tsung
    container_name: tsung_worker_2
    environment:
        - "SLAVE=true"
        - "constraint:node==bench-agent-2"
    networks:
      - tsung

networks:
  tsung:
    driver: overlay
```
